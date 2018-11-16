defmodule Ferry.Auth.EnsurePipeline do
  @moduledoc """
  A pipeline that fails if there is noone logged in.
  """

  use Guardian.Plug.Pipeline,
    otp_app: :ferry,
    error_handler: Ferry.Auth.ErrorHandler,
    module: Ferry.Auth.Guardian

  plug Guardian.Plug.EnsureAuthenticated
end