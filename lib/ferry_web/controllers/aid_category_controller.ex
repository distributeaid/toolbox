defmodule FerryWeb.AidCategoryController do
  use FerryWeb, :controller

  alias Ferry.AidTaxonomy
  alias Ferry.AidTaxonomy.Category

  # Read
  # ------------------------------------------------------------

  def index(conn, _params) do
    categories = AidTaxonomy.list_categories(true)
    render(conn, "index.html", categories: categories)
  end

  # NOTE: show route isn't needed

  # Create
  # ------------------------------------------------------------

  def new(conn, _params) do
    changeset = AidTaxonomy.change_category(%Category{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"category" => category_params}) do
    case AidTaxonomy.create_category(category_params) do
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
    category = AidTaxonomy.get_category!(id)
    changeset = AidTaxonomy.change_category(category)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"id" => id, "category" => category_params}) do
    category = AidTaxonomy.get_category!(id)
    case AidTaxonomy.update_category(category, category_params) do
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
    category = AidTaxonomy.get_category!(id)
    case AidTaxonomy.delete_category(category) do
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
