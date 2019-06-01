defmodule FerryWeb.RouteController do
  use FerryWeb, :controller

  alias Ferry.Shipments
  alias Ferry.Shipments.Route


  defp get_ids(params) do
    { Map.get(params, "group_id"), Map.get(params, "shipment_id"), Map.get(params, "id") }
  end

  defp sanitize_checklist(params, route_params) do
    route_params
    |> Map.put("shipment_id", params["shipment_id"])
    |> Map.put("checklist", (for {k, v} <- params, String.contains?(k, "checklist"), v != "", do: v))
  end

  def index(conn, params) do
    # could also create helpers to grab _actual_ group and shipments, but feels like
    # routes shouldn't have access to things above it/ what use case will it need to have entire shipment or group?
    { group_id, shipment_id, _ } = get_ids(params)
    #not passing in group because all groups involved with shipment should see route
    shipment = Shipments.get_shipment!(shipment_id)
    routes = Shipments.list_routes(shipment)

    render(conn, "index.html", group: group_id, shipment: shipment, routes: routes)
  end

  def new(conn, params) do
    changeset = Shipments.change_route(%Route{})
    { group_id, shipment_id, _ } = get_ids(params)
    shipment = Shipments.get_shipment!(shipment_id) |> Ferry.Repo.preload(:routes)
    render(conn, "new.html", group: group_id, shipment: shipment, changeset: changeset)
  end

  def create(conn, %{"route" => route_params} = params) do
    { group_id, shipment_id, _ } = get_ids(params)
    # adds checklist to params in proper form
    route_params = sanitize_checklist(params, route_params)

    case Shipments.create_route(route_params) do
      {:ok, route} ->
        conn
        |> put_flash(:info, "Route created successfully.")
        |> redirect(to: group_shipment_route_path(conn, :show, group_id, shipment_id, route))
      {:error, %Ecto.Changeset{} = changeset} ->
        shipment = Shipments.get_shipment!(shipment_id) |> Ferry.Repo.preload(:routes)
        render(conn, "new.html", group: group_id, shipment: shipment, changeset: changeset)
    end
  end

  def show(conn, params) do
    { group_id, shipment_id, route_id } = get_ids(params)
    route = Shipments.get_route!(route_id)
    render(conn, "show.html", group: group_id, shipment: shipment_id, route: route)
  end

  def edit(conn, params) do
    { group_id, shipment_id, route_id } = get_ids(params)

    shipment = Shipments.get_shipment!(shipment_id) |> Ferry.Repo.preload(:routes)
    route = Shipments.get_route!(route_id)
    changeset = Shipments.change_route(route)
    render(conn, "edit.html", group: group_id, shipment: shipment , route: route, changeset: changeset)
  end

  def update(conn, %{"route" => route_params} = params) do
    { group_id, shipment_id, route_id } = get_ids(params)

    route_params = sanitize_checklist(params, route_params)

    route = Shipments.get_route!(route_id)
    case Shipments.update_route(route, route_params) do
      {:ok, route} ->
        conn
        |> put_flash(:info, "Route updated successfully.")
        |> redirect(to: group_shipment_route_path(conn, :show, group_id, shipment_id, route))
      {:error, %Ecto.Changeset{} = changeset} ->
        shipment = Shipments.get_shipment!(shipment_id) |> Ferry.Repo.preload(:routes)
        render(conn, "edit.html", group: group_id, shipment: shipment, route: route, changeset: changeset)
    end
  end

  def delete(conn, params) do
    { group_id, shipment_id, route_id } = get_ids(params)

    route_id
    |> Shipments.get_route!
    |> Shipments.delete_route

    conn
    |> put_flash(:info, "Route deleted successfully.")
    |> redirect(to: group_shipment_route_path(conn, :index, group_id, shipment_id))
  end
end
