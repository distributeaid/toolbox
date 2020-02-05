defmodule FerryWeb.AidCategoryController do
  use FerryWeb, :controller

  alias Ferry.Aid
  alias Ferry.Aid.ItemCategory

  # Read
  # ------------------------------------------------------------

  def index(conn, _params) do
    categories = Aid.list_item_categories(true)
    render(conn, "index.html", categories: categories)
  end

  # NOTE: show route isn't needed

  # Create
  # ------------------------------------------------------------

  def new(conn, _params) do
    changeset = Aid.change_item_category(%ItemCategory{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"item_category" => category_params}) do
    case Aid.create_item_category(category_params) do
      {:ok, _category} ->
        conn
        |> put_flash(:info, "Category created successfully.")
        |> redirect(to: Routes.aid_item_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  # Update
  # ------------------------------------------------------------

  def edit(conn, %{"id" => id}) do
    category = Aid.get_item_category!(id)
    changeset = Aid.change_item_category(category)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"id" => id, "item_category" => category_params}) do
    category = Aid.get_item_category!(id)
    case Aid.update_item_category(category, category_params) do
      {:ok, _category} ->
        conn
        |> put_flash(:info, "Category updated successfully.")
        |> redirect(to: Routes.aid_item_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", changeset: changeset)
    end
  end

  # Delete
  # ------------------------------------------------------------

  def delete(conn, %{"id" => id}) do
    category = Aid.get_item_category!(id)
    case Aid.delete_item_category(category) do
      {:ok, _category} ->
        conn
        |> put_flash(:info, "Category and #{length(category.items)} related item(s) deleted successfully.  No items were linked to any aid list entries.")
        |> redirect(to: Routes.aid_item_path(conn, :index))

      # TODO: disable the delete button for categories you can't delete and show why on hover
      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_flash(:error, "Categories linked to aid list entries cannot be deleted, since doing so would also destroy user-data.")
        |> redirect(to: Routes.aid_item_path(conn, :index))
    end
  end

end
