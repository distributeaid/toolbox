defmodule FerryWeb.GroupController do
  use FerryWeb, :controller

  alias Ferry.Links
  alias Ferry.Locations
  alias Ferry.Profiles
  alias Ferry.Shipments

  # Group Controller
  # ==============================================================================

  # Helpers
  # ----------------------------------------------------------

  # TODO: test
  def groups_list_assigns(conn) do
    [
      groups: Profiles.list_groups()
    ]
  end

  # Show
  # ----------------------------------------------------------

  # TODO: add pagination
  def index(conn, _params) do
    render(conn, "index.html", groups: Profiles.list_groups())
  end

  # change (`debug_errors: true` to false in config/dev.exs if you want to
  # test website errors
  def show(conn, %{"id" => id}) do
    group = Profiles.get_group!(id)

    assigns = [
      groups: Profiles.list_groups(),
      group: group,
      links: Links.list_links(group),
      projects: Profiles.list_projects(group),
      addresses: Locations.list_addresses(group),
      shipments: Shipments.list_shipments(group)
    ]

    render(conn, "show.html", assigns)
  end

  # Create
  # ----------------------------------------------------------
  # Create groups using psql directly for now.  See `/README.md` for instructions.

  # Update
  # ----------------------------------------------------------

  def edit(conn, %{"id" => id}) do
    group = Profiles.get_group!(id)

    assigns = [
      groups: Profiles.list_groups(),
      group: group,
      changeset: Profiles.change_group(group),
    ]

    render(conn, "edit.html", assigns)
  end

  def update(conn, %{"id" => id, "group" => group_params}) do
    group = Profiles.get_group!(id)

    case Profiles.update_group(group, group_params) do
      {:ok, group} ->
        conn
        |> put_flash(:info, "Group updated successfully.")
        |> redirect(to: Routes.group_path(conn, :show, group))

      {:error, %Ecto.Changeset{} = changeset} ->
        assigns = [
          groups: Profiles.list_groups(),
          group: group,
          changeset: changeset,
        ]
        render(conn, "edit.html", assigns)
    end
  end

  # Delete
  # ----------------------------------------------------------

  def delete(conn, %{"id" => id}) do
    group = Profiles.get_group!(id)
    {:ok, _group} = Profiles.delete_group(group)

    conn
    |> put_flash(:info, "Group deleted successfully.")
    |> redirect(to: Routes.group_path(conn, :index))
  end

end
