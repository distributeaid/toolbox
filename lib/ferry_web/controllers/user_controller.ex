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
        |> redirect(to: home_page_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", group: group, changeset: changeset)
    end
  end
end
