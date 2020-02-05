defmodule FerryWeb.AidItemController do
  use FerryWeb, :controller

  alias Ferry.Aid
  alias Ferry.Aid.Item

  # Read
  # ------------------------------------------------------------

  def index(conn, _params) do
    categories = Aid.list_item_categories(true)
    render(conn, "index.html", categories: categories)
  end

  # Create
  # ------------------------------------------------------------

  def new(conn, %{"category_id" => category_id}) do
    categories = Aid.list_item_categories()
    mods = Aid.list_mods()
    changeset = Aid.change_item(%Item{category_id: category_id, mods: []})
    render(conn, "new.html", categories: categories, mods: mods, changeset: changeset)
  end

  def create(conn, %{"item" => item_params}) do
    category = Aid.get_item_category!(item_params["category_id"])
    case Aid.create_item(category, item_params) do
      {:ok, _item} ->
        conn
        |> put_flash(:info, "Item created successfully.")
        |> redirect(to: Routes.aid_item_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        categories = Aid.list_item_categories()
        mods = Aid.list_mods()
        render(conn, "new.html", categories: categories, mods: mods, changeset: changeset)
    end
  end

  # Update
  # ------------------------------------------------------------

  def edit(conn, %{"id" => id}) do
    categories = Aid.list_item_categories()
    mods = Aid.list_mods()
    item = Aid.get_item!(id)
    changeset = Aid.change_item(item)
    render(conn, "edit.html", categories: categories, mods: mods, changeset: changeset)
  end

  def update(conn, %{"id" => id, "item" => item_params}) do
    item = Aid.get_item!(id)
    case Aid.update_item(item, item_params) do
      {:ok, _item} ->
        conn
        |> put_flash(:info, "Item updated successfully.")
        |> redirect(to: Routes.aid_item_path(conn, :index))
      {:error, changeset} ->
        categories = Aid.list_item_categories()
        mods = Aid.list_mods()
        render(conn, "edit.html", categories: categories, mods: mods, changeset: changeset)
    end
  end

  # Delete
  # ------------------------------------------------------------

  def delete(conn, %{"id" => id}) do
    item = Aid.get_item!(id)
    case Aid.delete_item(item) do
      {:ok, _item} ->
        conn
        |> put_flash(:info, "Item deleted successfully.")
        |> redirect(to: Routes.aid_item_path(conn, :index))

      # TODO: test this case once ListEntires can be created in the UI
      # TODO: disable the delete button for items you can't delete and show why on hover
      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_flash(:error, "Items linked to aid list entries cannot be deleted, since doing so would destroy user-data.")
        |> redirect(to: Routes.aid_item_path(conn, :index))
    end
  end

end
