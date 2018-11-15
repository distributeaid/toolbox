defmodule Ferry.Auth.AuthAccessPipeline do
  @moduledoc """
  A pipeline to restrict access to certain endpoints based on authentication status.

  Based on: https://itnext.io/user-authentication-with-guardian-for-phoenix-1-3-web-apps-e2064cac0ec1
  """

  use Guardian.Plug.Pipeline, otp_app: :ferry

  plug(Guardian.Plug.VerifySession, claims: %{"typ" => "access"})
  plug(Guardian.Plug.EnsureAuthenticated)
  plug(Guardian.Plug.LoadResource)
end