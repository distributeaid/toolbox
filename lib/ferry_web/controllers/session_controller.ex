defmodule FerryWeb.SessionController do
  use FerryWeb, :controller
  import Ecto.Changeset

  alias Ferry.Accounts
  alias Ferry.Accounts.User
  alias Ferry.Auth
  alias Ferry.Auth.Guardian
  alias Ferry.Repo

  # Session Controller
  # ==============================================================================

  # Create
  # ----------------------------------------------------------

  def new(conn, _) do
    maybe_user = Guardian.Plug.current_resource(conn)
    if maybe_user do
      redirect(conn, to: Routes.home_page_path(conn, :index)) # TODO: test redirect
    else
      changeset = Accounts.change_user(%User{})
      render(conn, "new.html", changeset: changeset)
    end
  end

  def create(conn, %{"user" => %{"email" => email, "password" => password}}) do
    case Auth.authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> Guardian.Plug.sign_in(user)
        |> redirect(to: Routes.home_page_path(conn, :index))

      {:error, reason} ->
        changeset = User.validate_login(%User{}, %{email: email, password: password})
        |> Map.put(:action, :update)
        |> add_error(:login, "Email or password is incorrect.")

        conn
        |> put_flash(:error, to_string(reason))
        |> render("new.html", changeset: changeset)

    end
  end

  # Delete
  # ----------------------------------------------------------

  def delete(conn, _) do
    conn
    |> logout()
    |> redirect(to: Routes.home_page_path(conn, :index))
  end

  defp logout(conn) do
    conn
    |> Guardian.Plug.sign_out()
  end
end
