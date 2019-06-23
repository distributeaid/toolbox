defmodule FerryWeb.SessionController do
  use FerryWeb, :controller

  alias Ferry.Accounts
  alias Ferry.Accounts.User
  alias Ferry.Auth
  alias Ferry.Auth.Guardian

  # Session Controller
  # ==============================================================================

  # Create
  # ----------------------------------------------------------

  def new(conn, _) do
    changeset = Accounts.change_user(%User{})
    maybe_user = Guardian.Plug.current_resource(conn)
    if maybe_user do
      redirect(conn, to: Routes.home_page_path(conn, :index)) # TODO: test redirect
    else
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
        conn
        |> put_flash(:error, to_string(reason))
        |> new(%{})
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
