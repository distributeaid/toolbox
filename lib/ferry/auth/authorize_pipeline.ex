defmodule Ferry.Auth.AuthorizePipeline do
  @moduledoc """
  A pipeline that fails if the logged in user isn't associated with the group
  related to the current resource being accessed.
  """
  use Guardian.Plug.Pipeline,
    otp_app: :ferry,
    error_handler: Ferry.Auth.ErrorHandler,
    module: Ferry.Auth.Guardian

  alias Ferry.Auth.ErrorHandler

  # TODO: replace w/ finer grained permissions via [Canary](https://github.com/cpjk/canary)
  #       example: https://github.com/digitalnatives/course_planner/blob/27b1c8067edc262685e9c4dcbfcf82633bc8b8dc/lib/course_planner_web/controllers/permissions.ex
  defp authorize_for_resource(conn, _) do
    if to_string(conn.assigns.current_user.group_id) == Enum.at(conn.path_info, 1) do
      conn
    else
      ErrorHandler.authorization_error(conn, "Not Authorized")
    end
  end

  plug :authorize_for_resource
end