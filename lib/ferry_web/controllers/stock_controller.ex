defmodule FerryWeb.StockController do
  use FerryWeb, :controller

  alias Ferry.Profiles
  alias Ferry.Inventory
  alias Ferry.Inventory.Stock

  # Stock Controller
  # ==============================================================================

  # Helpers
  # ----------------------------------------------------------

  # TODO: copied from group_controller, refactor into shared function or something
  defp current_group(_conn = %{assigns: %{current_user: %{group_id: group_id}}}) do
    Profiles.get_group!(group_id)
  end

  defp current_group(_conn) do
    nil
  end

  # Show
  # ------------------------------------------------------------
  
  def index(conn, %{"group_id" => group_id}) do
    group = Profiles.get_group!(group_id)
    stocks = Inventory.list_stocks()
    render(conn, "index.html", group: group, stocks: stocks)
  end

  def show(conn, %{"group_id" => group_id, "id" => id}) do
    group = Profiles.get_group!(group_id)
    stock = Inventory.get_stock!(id)
    render(conn, "show.html", group: group, stock: stock)
  end

  # Create
  # ------------------------------------------------------------

  def new(conn, %{"group_id" => group_id}) do
    group = Profiles.get_group!(group_id)
    projects = Profiles.list_projects(group)
    changeset = Inventory.change_stock(%Stock{})
    render(conn, "new.html", group: group, projects: projects, changeset: changeset)
  end

  def create(conn, %{"group_id" => group_id, "stock" => stock_params}) do
    group = Profiles.get_group!(group_id)

    case Inventory.create_stock(stock_params) do
      {:ok, stock} ->
        conn
        |> put_flash(:info, "Stock created successfully.")
        |> redirect(to: group_stock_path(conn, :index, group))
      {:error, %Ecto.Changeset{} = changeset} ->
        projects = Profiles.list_projects(group)
        render(conn, "new.html", group: group, projects: projects, changeset: changeset)
    end
  end

  # Update
  # ------------------------------------------------------------

  def edit(conn, %{"group_id" => group_id, "id" => id}) do
    group = Profiles.get_group!(group_id)
    projects = Profiles.list_projects(group)
    stock = Inventory.get_stock!(id)
    changeset = Inventory.change_stock(stock)
    render(conn, "edit.html", group: group, projects: projects, stock: stock, changeset: changeset)
  end

  def update(conn, %{"group_id" => group_id, "id" => id, "stock" => stock_params}) do
    group = Profiles.get_group!(group_id)
    stock = Inventory.get_stock!(id)

    case Inventory.update_stock(stock, stock_params) do
      {:ok, stock} ->
        conn
        |> put_flash(:info, "Stock updated successfully.")
        |> redirect(to: group_stock_path(conn, :index, group))
      {:error, %Ecto.Changeset{} = changeset} ->
        projects = Profiles.list_projects(group)
        render(conn, "edit.html", group: group, projects: projects, stock: stock, changeset: changeset)
    end
  end

  # Delete
  # ------------------------------------------------------------

  def delete(conn, %{"group_id" => group_id, "id" => id}) do
    group = Profiles.get_group!(group_id)
    stock = Inventory.get_stock!(id)
    {:ok, _stock} = Inventory.delete_stock(stock)

    conn
    |> put_flash(:info, "Stock deleted successfully.")
    |> redirect(to: group_stock_path(conn, :index, group))
  end
end
