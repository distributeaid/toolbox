defmodule Ferry.Auth do
  @moduledoc """
  The Auth context.

  Based on: https://itnext.io/user-authentication-with-guardian-for-phoenix-1-3-web-apps-e2064cac0ec1
  """

  import Ecto.Query, warn: false
  import Plug.Conn

  alias Ferry.Repo
  alias Ferry.Auth.Guardian
  alias Ferry.Accounts.User

  @doc """
  TODO
  """
  def authenticate_user(email, given_password) do
    Repo.get_by(User, email: email)
    |> check_password(given_password)
  end

  defp check_password(nil, _), do: {:error, "Incorrect username or password"}

  defp check_password(user, given_password) do
    case Bcrypt.verify_pass(given_password, user.password_hash) do
      true -> {:ok, user}
      false -> {:error, "Incorrect username or password"}
    end
  end

  @doc """
  TODO
  """
  def login(conn, user) do
    conn
    |> Guardian.Plug.sign_in(user)
    |> assign(:current_user, user)
  end

  @doc """
  TODO
  """
  def load_current_user(conn, _) do
    conn
    |> assign(:current_user, Guardian.Plug.current_resource(conn))
  end

  @doc """
  TODO
  """
  def logout(conn) do
    conn
    |> Guardian.Plug.sign_out()
  end
end
