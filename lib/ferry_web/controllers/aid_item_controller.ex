defmodule FerryWeb.AidItemController do
  use FerryWeb, :controller

  alias Ferry.AidTaxonomy
  alias Ferry.AidTaxonomy.Item

  # Read
  # ------------------------------------------------------------

  def index(conn, _params) do
    categories = AidTaxonomy.list_categories(true)
    render(conn, "index.html", categories: categories)
  end

  # Create
  # ------------------------------------------------------------

  def new(conn, %{"category_id" => category_id}) do
    categories = AidTaxonomy.list_categories()
    mods = AidTaxonomy.list_mods()
    changeset = AidTaxonomy.change_item(%Item{category_id: category_id, mods: []})
    render(conn, "new.html", categories: categories, mods: mods, changeset: changeset)
  end

  def create(conn, %{"item" => item_params}) do
    category = AidTaxonomy.get_category!(item_params["category_id"])
    case AidTaxonomy.create_item(category, item_params) do
      {:ok, _item} ->
        conn
        |> put_flash(:info, "Item created successfully.")
        |> redirect(to: Routes.aid_item_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        categories = AidTaxonomy.list_categories()
        mods = AidTaxonomy.list_mods()
        render(conn, "new.html", categories: categories, mods: mods, changeset: changeset)
    end
  end

  # Update
  # ------------------------------------------------------------

  def edit(conn, %{"id" => id}) do
    categories = AidTaxonomy.list_categories()
    mods = AidTaxonomy.list_mods()
    item = AidTaxonomy.get_item!(id)
    changeset = AidTaxonomy.change_item(item)
    render(conn, "edit.html", categories: categories, mods: mods, changeset: changeset)
  end

  def update(conn, %{"id" => id, "item" => item_params}) do
    item = AidTaxonomy.get_item!(id)
    case AidTaxonomy.update_item(item, item_params) do
      {:ok, _item} ->
        conn
        |> put_flash(:info, "Item updated successfully.")
        |> redirect(to: Routes.aid_item_path(conn, :index))
      {:error, changeset} ->
        categories = AidTaxonomy.list_categories()
        mods = AidTaxonomy.list_mods()
        render(conn, "edit.html", categories: categories, mods: mods, changeset: changeset)
    end
  end

  # Delete
  # ------------------------------------------------------------

  def delete(conn, %{"id" => id}) do
    item = AidTaxonomy.get_item!(id)
    case AidTaxonomy.delete_item(item) do
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
