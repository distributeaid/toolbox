defmodule Ferry.Auth.SetupPipeline do
  @moduledoc """
  A pipeline that implements "maybe" authenticated. Use `Ferry.Auth.EnsurePipeline` to make sure someone is logged in.
  """

  use Guardian.Plug.Pipeline,
    otp_app: :ferry,
    error_handler: Ferry.Auth.ErrorHandler,
    module: Ferry.Auth.Guardian

  defp assign_current_user(conn, _) do
    assign(conn, :current_user, Guardian.Plug.current_resource(conn))
  end

  # If there is a session token, restrict it to an access token and validate it
  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}

  # If there is an authorization header, restrict it to an access token and validate it
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}

  # Load the user if either of the verifications worked
  plug Guardian.Plug.LoadResource, allow_blank: true

  # Assign the current_user parameter so every page can use it.
  plug :assign_current_user
end