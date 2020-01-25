defmodule FerryWeb.ShipmentOverviewController do
  use FerryWeb, :controller

  alias Ferry.Shipments
  alias Ferry.Profiles
  alias Ferry.Manifests


  # Shipment Controller
  # ==============================================================================

  # Helpers
  # ------------------------------------------------------------

  # TODO: copied from group_controller, refactor into shared function or something
  defp current_group(_conn = %{assigns: %{current_user: %{group_id: group_id}}}) do
    Profiles.get_group!(group_id)
  end

  defp current_group(_conn) do
    nil
  end

  # Show
  # ------------------------------------------------------------

  def index(conn, _params) do
    shipments = Shipments.list_shipments()
    render(conn, "index.html", shipments: shipments, current_group: current_group(conn))
  end

  # TODO: needs to throw an error if the group doesn't have an assigned role in the shipment
  #       currently provides edit access to any shipment
  #       we should probably check this more generally, since our auth system
  #       only compares the logged in group to the group specified in the
  #       route, but doesn't check that the group in the route has access to
  #       a specific sub-resource
  def show(conn, %{"id" => id} = _params) do
    shipment = Shipments.get_shipment!(id)
    routes = Shipments.list_routes(shipment)
    needs = Manifests.list_needs(shipment)
    
    render(conn, "show.html",      
      shipment: shipment,
      routes: routes,
      needs: needs,
      current_group: current_group(conn)
    )
  end

end