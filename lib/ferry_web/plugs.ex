defmodule FerryWeb.Plugs do
  import Plug.Conn

  alias Ferry.Profiles

  # Assign Current Group
  # ------------------------------------------------------------
  # NOTE: assumes Ferry.Auth.SetupPipeline has already been called in the router pipeline
  def assign_current_group(%{assigns: %{current_user: %{group_id: group_id}}} = conn, _opts) do
    assign(conn, :current_group, Profiles.get_group!(group_id))
  end

  def assign_current_group(conn, _opts) do
    assign(conn, :current_group, nil)
  end

end
