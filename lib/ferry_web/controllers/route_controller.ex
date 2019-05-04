defmodule FerryWeb.RouteController do
  use FerryWeb, :controller

  alias Ferry.Shipments
  alias Ferry.Shipments.Route

  def index(conn, _params) do
    routes = Shipments.list_routes()
    render(conn, "index.html", routes: routes)
  end

  def new(conn, _params) do
    changeset = Shipments.change_route(%Route{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"route" => route_params}) do
    group = 1
    shipment = 1
    case Shipments.create_route(route_params) do
      {:ok, route} ->
        conn
        |> put_flash(:info, "Route created successfully.")
        |> redirect(to: group_shipment_route_path(conn, :index, group, shipment, route))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    route = Shipments.get_route!(id)
    render(conn, "show.html", route: route)
  end

  def edit(conn, %{"id" => id}) do
    route = Shipments.get_route!(id)
    changeset = Shipments.change_route(route)
    render(conn, "edit.html", route: route, changeset: changeset)
  end

  def update(conn, %{"id" => id, "route" => route_params}) do
    route = Shipments.get_route!(id)
    group = 1
    shipment = 1
    case Shipments.update_route(route, route_params) do
      {:ok, route} ->
        conn
        |> put_flash(:info, "Route updated successfully.")
        |> redirect(to: group_shipment_route_path(conn, :index, group, shipment, route))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", route: route, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    route = Shipments.get_route!(id)
    {:ok, _route} = Shipments.delete_route(route)
    group = 1
    shipment = 1

    conn
    |> put_flash(:info, "Route deleted successfully.")
    |> redirect(to: group_shipment_route_path(conn, :index, group, shipment))
  end
end
