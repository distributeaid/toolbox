defmodule FerryWeb.RouteView do
  use FerryWeb, :view

  def has_routes?(routes) do
    length(routes) > 0
  end

  def has_checklist?(path_info, checklist) do
    ((List.last(path_info) == "new") or (List.last(path_info) == "edit" and length(checklist) == 0))
  end

end
