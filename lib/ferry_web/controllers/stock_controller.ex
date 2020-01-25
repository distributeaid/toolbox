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
    stocks = Inventory.list_stocks(group)
    render(conn, "index.html", current_group: current_group(conn), group: group, stocks: stocks)
  end

  # Create
  # ------------------------------------------------------------

  def new(conn, %{"group_id" => group_id}) do
    group = Profiles.get_group!(group_id)
    projects = Profiles.list_projects(group)
    categories = Inventory.list_top_categories()
    items = Inventory.list_top_items()
    changeset = Inventory.change_stock(%Stock{})
    render(conn, "new.html", current_group: current_group(conn), group: group, projects: projects, categories: categories, items: items, changeset: changeset)
  end

  def create(conn, %{"group_id" => group_id, "stock" => stock_params}) do
    group = Profiles.get_group!(group_id)

    case Inventory.create_stock(stock_params) do
      {:ok, _stock} ->
        conn
        |> put_flash(:info, "Stock created successfully.")
        |> redirect(to: Routes.group_stock_path(conn, :index, group))
      {:error, %Ecto.Changeset{} = changeset} ->
        projects = Profiles.list_projects(group)
        categories = Inventory.list_top_categories()
        items = Inventory.list_top_items()
        render(conn, "new.html", current_group: current_group(conn), group: group, projects: projects, categories: categories, items: items, changeset: changeset)
    end
  end

  # Update
  # ------------------------------------------------------------

  def edit(conn, %{"group_id" => group_id, "id" => id}) do
    group = Profiles.get_group!(group_id)
    projects = Profiles.list_projects(group)
    categories = Inventory.list_top_categories()
    items = Inventory.list_top_items()
    stock = Inventory.get_stock!(id)
    changeset = Inventory.change_stock(stock)
    render(conn, "edit.html", current_group: current_group(conn), group: group, projects: projects, categories: categories, items: items, stock: stock, changeset: changeset)
  end

  def update(conn, %{"group_id" => group_id, "id" => id, "stock" => stock_params}) do
    group = Profiles.get_group!(group_id)
    stock = Inventory.get_stock!(id)

    case Inventory.update_stock(stock, stock_params) do
      {:ok, _stock} ->
        conn
        |> put_flash(:info, "Stock updated successfully.")
        |> redirect(to: Routes.group_stock_path(conn, :index, group))
      {:error, %Ecto.Changeset{} = changeset} ->
        projects = Profiles.list_projects(group)
        categories = Inventory.list_top_categories()
        items = Inventory.list_top_items()
        render(conn, "edit.html", current_group: current_group(conn), group: group, projects: projects, categories: categories, items: items, stock: stock, changeset: changeset)
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
    |> redirect(to: Routes.group_stock_path(conn, :index, group))
  end
end
