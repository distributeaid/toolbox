defmodule FerryWeb.HomePageController do
  use FerryWeb, :controller


  # Home Page Controller
  # ================================================================================

  # Show
  # ------------------------------------------------------------

  def index(%{assigns: assigns} = conn, _params) do
    case assigns[:current_group] do
      nil -> render conn, "index-public.html"
      group -> render conn, "index-group.html", group: group
    end
  end
end
