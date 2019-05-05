defmodule FerryWeb.RouteView do
  use FerryWeb, :view

  def has_routes?(routes) do
    length(routes) > 0
  end

end
