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

  # TODO: add pagination?
  def index(conn, %{"group_id" => group_id}) do
    group = Profiles.get_group!(group_id)
    projects = Profiles.list_projects(group)
    render(conn, "index.html", group: group, projects: projects)
  end

  # TODO: add pagination
  def index(conn, _params) do
    projects = Profiles.list_projects()
    render(conn, "index-all.html", projects: projects, current_group: current_group(conn))
  end

  def show(conn, %{"group_id" => group_id, "id" => id}) do
    group = Profiles.get_group!(group_id)
    project = Profiles.get_project!(id)
    render(conn, "show.html", group: group, project: project)
  end

  # Create
  # ----------------------------------------------------------

  def new(conn, %{"group_id" => group_id}) do
    group = Profiles.get_group!(group_id)
    changeset = Profiles.change_project(%Project{})
    render(conn, "new.html", group: group, changeset: changeset)
  end

  def create(conn, %{"group_id" => group_id, "project" => project_params}) do
    group = Profiles.get_group!(group_id)

    case Profiles.create_project(group, project_params) do
      {:ok, _project} ->
        conn
        |> put_flash(:info, "Project created successfully.")
        |> redirect(to: group_path(conn, :show, group))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", group: group, changeset: changeset)
    end
  end

    # Update
    # ----------------------------------------------------------

  def edit(conn, %{"group_id" => group_id, "id" => id}) do
    group = Profiles.get_group!(group_id)
    project = Profiles.get_project!(id)
    changeset = Profiles.change_project(project)
    render(conn, "edit.html", group: group, project: project, changeset: changeset)
  end

  def update(conn, %{"group_id" => group_id, "id" => id, "project" => project_params}) do
    group = Profiles.get_group!(group_id)
    project = Profiles.get_project!(id)

    case Profiles.update_project(project, project_params) do
      {:ok, _project} ->
        conn
        |> put_flash(:info, "Project updated successfully.")
        |> redirect(to: group_path(conn, :show, group))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", group: group, project: project, changeset: changeset)
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
    |> redirect(to: group_path(conn, :show, group))
  end
end
