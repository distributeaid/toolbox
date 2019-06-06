defmodule FerryWeb.HomePageController do
  use FerryWeb, :controller

  alias Ferry.Profiles


  # Home Page Controller
  # ================================================================================
  

  # Helpers
  # ------------------------------------------------------------
  
  # TODO: copied from group controller.  refactor
  defp current_group(_conn = %{assigns: %{current_user: %{group_id: group_id}}}) do
    Profiles.get_group!(group_id)
  end

  defp current_group(_conn) do
    nil
  end

  # Show
  # ------------------------------------------------------------

  def index(conn, _params) do
    case current_group(conn) do
      nil -> render conn, "index-public.html"
      group -> render conn, "index-group.html", group: group
    end
  end
end
