defmodule FerryWeb.UserController do
  use FerryWeb, :controller

  alias Ferry.Accounts
  alias Ferry.Accounts.User
  alias Ferry.Profiles

  # User Controller
  # ==============================================================================

  # Create
  # ----------------------------------------------------------

  def new(conn, %{"group_id" => group_id}) do
    group = Profiles.get_group!(group_id)
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", group: group, changeset: changeset)
  end

  def create(conn, %{"group_id" => group_id, "user" => user_params}) do
    group = Profiles.get_group!(group_id)
    case Accounts.create_user(group, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: Routes.home_page_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", group: group, changeset: changeset)
    end
  end

  # Update
  # ----------------------------------------------------------

  def edit(conn, %{"group_id" => group_id, "id" => id}) do
    group = Profiles.get_group!(group_id)
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", group: group, user: user, changeset: changeset)
  end

  def update(conn, %{"group_id" => group_id, "id" => id, "user" => user_params}) do
    group = Profiles.get_group!(group_id)
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.home_page_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", group: group, changeset: changeset)
    end
  end

end
