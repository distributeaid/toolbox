defmodule Ferry.Auth.ErrorHandler do
  @moduledoc """
  A pipeline to handle authentication errors.
  """
  use FerryWeb, :controller

  alias FerryWeb.ErrorView

  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> put_status(401)
    |> put_view(ErrorView)
    |> render(:"401", message: to_string(type))
  end

  def authorization_error(conn, type) do
    conn
    |> put_status(403)
    |> put_view(ErrorView)
    |> render(:"403", message: to_string(type))
    |> halt
  end
end