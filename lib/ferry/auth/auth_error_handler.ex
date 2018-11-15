defmodule Ferry.Auth.AuthErrorHandler do
  @moduledoc """
  A pipeline to handle authentication errors.

  Based on: https://itnext.io/user-authentication-with-guardian-for-phoenix-1-3-web-apps-e2064cac0ec1
  """
  use FerryWeb, :controller

  import Plug.Conn

  alias FerryWeb.ErrorView

  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> put_status(401)
    |> put_view(ErrorView)
    |> render(:"401", message: type)
  end
end