defmodule FerryWeb.ProjectController do
  use FerryWeb, :controller

  alias Ferry.Profiles
  alias Ferry.Profiles.Project

  # Project Controller
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
  # ----------------------------------------------------------
  # None for now.

  # Create
  # ----------------------------------------------------------

  def new(conn, %{"group_id" => group_id}) do
    group = Profiles.get_group!(group_id)
    changeset = Profiles.change_project(%Project{})
    render(conn, "new.html", current_group: current_group(conn), group: group, changeset: changeset)
  end

  def create(conn, %{"group_id" => group_id, "project" => project_params}) do
    group = Profiles.get_group!(group_id)

    case Profiles.create_project(group, project_params) do
      {:ok, _project} ->
        conn
        |> put_flash(:info, "Project created successfully.")
        |> redirect(to: Routes.group_path(conn, :show, group))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", current_group: current_group(conn), group: group, changeset: changeset)
    end
  end

    # Update
    # ----------------------------------------------------------

  def edit(conn, %{"group_id" => group_id, "id" => id}) do
    group = Profiles.get_group!(group_id)
    project = Profiles.get_project!(id)
    changeset = Profiles.change_project(project)
    render(conn, "edit.html", current_group: current_group(conn), group: group, project: project, changeset: changeset)
  end

  def update(conn, %{"group_id" => group_id, "id" => id, "project" => project_params}) do
    group = Profiles.get_group!(group_id)
    project = Profiles.get_project!(id)

    case Profiles.update_project(project, project_params) do
      {:ok, _project} ->
        conn
        |> put_flash(:info, "Project updated successfully.")
        |> redirect(to: Routes.group_path(conn, :show, group))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", current_group: current_group(conn), group: group, project: project, changeset: changeset)
    end
  end

    # Delete
    # ----------------------------------------------------------

  def delete(conn, %{"group_id" => group_id, "id" => id}) do
    group = Profiles.get_group!(group_id)
    project = Profiles.get_project!(id)
    {:ok, _project} = Profiles.delete_project(project)

    conn
    |> put_flash(:info, "Project deleted successfully.")
    |> redirect(to: Routes.group_path(conn, :show, group))
  end
end
