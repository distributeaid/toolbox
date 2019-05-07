defmodule FerryWeb.RouteController do
  use FerryWeb, :controller

  alias Ferry.Shipments
  alias Ferry.Shipments.Route

  defp get_ids(params) do
    { Map.get(params, "group_id"), Map.get(params, "shipment_id"), Map.get(params, "id") }
  end

  def index(conn, params) do
    # could also create helpers to grab _actual_ group and shipments, but feels like
    # routes shouldn't have access to things above it/ what use case will it need to have entire shipment or group?
    { group_id, shipment_id, _ } = get_ids(params)
    #not passing in group because all groups involved with shipment should see route
    routes = Shipments.list_routes(shipment_id)

    render(conn, "index.html", group: group_id, shipment: shipment_id, routes: routes)
  end

  def new(conn, params) do
    changeset = Shipments.change_route(%Route{})
    { group_id, shipment_id, _ } = get_ids(params)
    render(conn, "new.html", group: group_id, shipment: shipment_id, changeset: changeset)
  end

  def create(conn, %{"route" => route_params} = params) do
    { group_id, shipment_id, _ } = get_ids(params)
    route_params = Map.put(route_params, "shipment_id", shipment_id)
    IO.puts("++++++++++++++++++++")
    IO.puts("++++++++++++++++++++")
    IO.inspect(params)
    IO.puts("++++++++++++++++++++")

    case Shipments.create_route(route_params) do
      {:ok, route} ->
        conn
        |> put_flash(:info, "Route created successfully.")
        |> redirect(to: group_shipment_route_path(conn, :show, group_id, shipment_id, route))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", group: group_id, shipment: shipment_id, changeset: changeset)
    end
  end

  def show(conn, params) do
    { group_id, shipment_id, route_id } = get_ids(params)
    route = Shipments.get_route!(route_id)
    render(conn, "show.html", group: group_id, shipment: shipment_id, route: route)
  end

  def edit(conn, params) do
    { group_id, shipment_id, route_id } = get_ids(params)

    route = Shipments.get_route!(route_id)
    changeset = Shipments.change_route(route)
    render(conn, "edit.html", group: group_id, shipment: shipment_id, route: route, changeset: changeset)
  end

  def update(conn, %{"route" => route_params} = params) do
    { group_id, shipment_id, route_id } = get_ids(params)
    route = Shipments.get_route!(route_id)
    case Shipments.update_route(route, route_params) do
      {:ok, route} ->
        conn
        |> put_flash(:info, "Route updated successfully.")
        |> redirect(to: group_shipment_route_path(conn, :show, group_id, shipment_id, route))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", group: group_id, shipment: shipment_id, route: route, changeset: changeset)
    end
  end

  def delete(conn, params) do
    { group_id, shipment_id, route_id } = get_ids(params)

    route_id
    |> Shipments.get_route!
    |> Shipments.delete_route

    routes = Shipments.list_routes(shipment_id)

    conn
    |> put_flash(:info, "Route deleted successfully.")
    |> redirect(to: group_shipment_route_path(conn, :index, group_id, shipment_id, routes))
  end
end
