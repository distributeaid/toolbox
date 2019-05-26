defmodule FerryWeb.RouteView do
  use FerryWeb, :view

  def has_routes?(routes) do
    length(routes) > 0
  end

  def has_checklist?(path_info, route) do
    route = List.first(route)

    ((List.last(path_info) == "edit") and (length(route.checklist) > 0))
  end

end
