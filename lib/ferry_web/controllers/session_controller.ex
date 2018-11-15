defmodule FerryWeb.SessionController do
  use FerryWeb, :controller

  alias Ferry.Auth

  # Session Controller
  # ==============================================================================
  
  # Create
  # ----------------------------------------------------------

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"email" => email, "password" => password}) do
    case Ferry.Auth.authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> Auth.login(user)
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: group_path(conn, :index))

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid username/password combination")
        |> render("new.html")
    end
  end

  # Delete
  # ----------------------------------------------------------

  def delete(conn, _) do
    conn
    |> Auth.logout()
    |> redirect(to: home_page_path(conn, :index))
  end
end
