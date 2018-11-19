defmodule FerryWeb.LinkController do
  use FerryWeb, :controller

  alias Ferry.Profiles
  alias Ferry.Links
  alias Ferry.Links.Link

  # Link Controller
  # ==============================================================================

  # Show
  # ----------------------------------------------------------

  def index(conn, %{"group_id" => group_id}) do
    group = Profiles.get_group!(group_id)
    links = Links.list_links(group)
    render(conn, "index.html", group: group, links: links)
  end

  def show(conn, %{"group_id" => group_id, "id" => id}) do
    group = Profiles.get_group!(group_id)
    link = Links.get_link!(id)
    render(conn, "show.html", group: group, link: link)
  end

  # Create
  # ----------------------------------------------------------

  def new(conn, %{"group_id" => group_id}) do
    group = Profiles.get_group!(group_id)
    changeset = Links.change_link(%Link{})
    render(conn, "new.html", group: group, changeset: changeset)
  end

  def create(conn, %{"group_id" => group_id, "link" => link_params}) do
    group = Profiles.get_group!(group_id)

    case Links.create_link(group, link_params) do
      {:ok, link} ->
        conn
        |> put_flash(:info, "Link created successfully.")
        |> redirect(to: group_link_path(conn, :show, group, link))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", group: group, changeset: changeset)
    end
  end

  # Update
  # ----------------------------------------------------------

  def edit(conn, %{"group_id" => group_id, "id" => id}) do
    group = Profiles.get_group!(group_id)
    link = Links.get_link!(id)
    changeset = Links.change_link(link)
    render(conn, "edit.html", group: group, link: link, changeset: changeset)
  end

  def update(conn, %{"group_id" => group_id, "id" => id, "link" => link_params}) do
    group = Profiles.get_group!(group_id)
    link = Links.get_link!(id)

    case Links.update_link(link, link_params) do
      {:ok, link} ->
        conn
        |> put_flash(:info, "Link updated successfully.")
        |> redirect(to: group_link_path(conn, :show, group, link))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", group: group, link: link, changeset: changeset)
    end
  end

  # Delete
  # ----------------------------------------------------------

  def delete(conn, %{"group_id" => group_id, "id" => id}) do
    group = Profiles.get_group!(group_id)
    link = Links.get_link!(id)
    {:ok, _link} = Links.delete_link(link)

    conn
    |> put_flash(:info, "Link deleted successfully.")
    |> redirect(to: group_link_path(conn, :index, group))
  end
end