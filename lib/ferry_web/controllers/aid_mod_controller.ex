defmodule FerryWeb.AidModController do
  use FerryWeb, :controller

  alias Ferry.Aid
  alias Ferry.Aid.Mod

  # Read
  # ------------------------------------------------------------

  def index(conn, _params) do
    mods = Aid.list_mods()
    render(conn, "index.html", mods: mods)
  end

  # Create
  # ------------------------------------------------------------

  def new(conn, _params) do
    categories = Aid.list_item_categories()
    changeset = Aid.change_mod(%Mod{items: []})
    render(conn, "new.html", categories: categories, changeset: changeset)
  end

  def create(conn, %{"mod" => mod_params}) do
    case Aid.create_mod(mod_params) do
      {:ok, _mod} ->
        conn
        |> put_flash(:info, "Item created successfully.")
        |> redirect(to: Routes.aid_mod_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        categories = Aid.list_item_categories()
        render(conn, "new.html", categories: categories, changeset: changeset)
    end
  end

  # Update
  # ------------------------------------------------------------

  def edit(conn, %{"id" => id}) do
    categories = Aid.list_item_categories()
    mod = Aid.get_mod!(id)
    changeset = Aid.change_mod(mod)
    render(conn, "edit.html", categories: categories, changeset: changeset)
  end

  def update(conn, %{"id" => id, "mod" => mod_params}) do
    mod = Aid.get_mod!(id)
    case Aid.update_mod(mod, mod_params) do
      {:ok, _mod} ->
        conn
        |> put_flash(:info, "Mod updated successfully.")
        |> redirect(to: Routes.aid_mod_path(conn, :index))
      {:error, changeset} ->
        categories = Aid.list_item_categories()
        render(conn, "edit.html", categories: categories, changeset: changeset)
    end
  end

  # Delete
  # ------------------------------------------------------------

  def delete(conn, %{"id" => id}) do
    mod = Aid.get_mod!(id)
    case Aid.delete_mod(mod) do
      {:ok, _mod} ->
        conn
        |> put_flash(:info, "Mod deleted successfully.")
        |> redirect(to: Routes.aid_mod_path(conn, :index))

      # TODO: test this case once ModValues can be created in the UI
      # TODO: disable the delete button for mods you can't delete and show why on hover
      {:error,  %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Aid list entries have set values for this mod, so it cannot be deleted since doing so would destroy user-data.")
        |> redirect(to: Routes.aid_mod_path(conn, :index))
    end
  end

end
