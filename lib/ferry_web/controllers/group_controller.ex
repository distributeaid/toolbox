defmodule FerryWeb.GroupController do
  use FerryWeb, :controller

  alias Ferry.Profiles
  alias Ferry.Profiles.Group

  # Group Controller
  # ==============================================================================

  # Show
  # ----------------------------------------------------------

  # TODO: add pagination
  def index(conn, _params) do
    groups = Profiles.list_groups()
    render(conn, "index.html", groups: groups)
  end

  # TODO: show group-specific 404 page - "couldn't find the group you were looking for"
  #       currently this function errors out with an invalid ID, which somehow
  #       results in the 404 page being shown when debug mode is turned off
  #       (`debug_errors: true` in config/dev.exs)
  def show(conn, %{"id" => id}) do
    group = Profiles.get_group!(id)
    render(conn, "show.html", group: group)
  end

  # Create
  # ----------------------------------------------------------

  def new(conn, _params) do
    changeset = Profiles.change_group(%Group{})
    render(conn, "new.html", changeset: changeset)
  end

  # TODO: trying to keep it on `/groups/new` after you submit the form with an error
  #.      currently the url changes to `/groups` (though the new group form is still rendered)
  def create(conn, %{"group" => group_params}) do
    case Profiles.create_group(group_params) do
      {:ok, group} ->
        conn
        |> put_flash(:info, "Group created successfully.")
        |> redirect(to: group_path(conn, :show, group))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  # Update
  # ----------------------------------------------------------

  def edit(conn, %{"id" => id}) do
    group = Profiles.get_group!(id)
    changeset = Profiles.change_group(group)
    render(conn, "edit.html", group: group, changeset: changeset)
  end

  def update(conn, %{"id" => id, "group" => group_params}) do
    group = Profiles.get_group!(id)

    case Profiles.update_group(group, group_params) do
      {:ok, group} ->
        conn
        |> put_flash(:info, "Group updated successfully.")
        |> redirect(to: group_path(conn, :show, group))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", group: group, changeset: changeset)
    end
  end

  # Delete
  # ----------------------------------------------------------

  def delete(conn, %{"id" => id}) do
    group = Profiles.get_group!(id)
    {:ok, _group} = Profiles.delete_group(group)

    conn
    |> put_flash(:info, "Group deleted successfully.")
    |> redirect(to: group_path(conn, :index))
  end

end
