defmodule FerryWeb.UserController do
  use FerryWeb, :controller

  alias Ferry.Accounts
  alias Ferry.Accounts.User
  alias Ferry.Profiles

  # User Controller
  # ==============================================================================

  # Create
  # ----------------------------------------------------------

  # add user to a group
  def new(conn, %{"group_id" => group_id}) do
    group = Profiles.get_group!(group_id)
    changeset = Accounts.change_user(%User{})
    render(conn, "add.html", group: group, changeset: changeset)
  end

  # add user and a group
  def new(conn, _) do
    maybe_user = Guardian.Plug.current_resource(conn)
    if maybe_user do
      redirect(conn, to: Routes.home_page_path(conn, :index)) # TODO: test redirect
    else
      changeset = Accounts.change_user(%User{})
      render(conn, "new.html", changeset: changeset)
    end
  end

  # add user to a group
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

  # add user and a group
  # TODO: needs a group in the account context & transactions
  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user_and_group(user_params) do
      {:ok, _user_and_group} ->
        conn
        |> put_flash(:info, "Account created successfully.")
        |> redirect(to: Routes.session_path(conn, :new))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
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
