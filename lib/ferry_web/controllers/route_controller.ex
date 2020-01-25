defmodule FerryWeb.RouteController do
  use FerryWeb, :controller

  alias Ferry.Shipments
  alias Ferry.Shipments.Route
  alias Ferry.Profiles

  # Route Controller
  # ==============================================================================

  # Helpers
  # ----------------------------------------------------------

  # adds checklist to params in proper form
  defp sanitize_checklist(params, route_params) do
    route_params
    |> Map.put("shipment_id", params["shipment_id"])
    |> Map.put("checklist", (for {k, v} <- params, String.contains?(k, "checklist"), v != "", do: v))
  end

  # TODO: copied from group_controller, refactor into shared function or something
  defp current_group(_conn = %{assigns: %{current_user: %{group_id: group_id}}}) do
    Profiles.get_group!(group_id)
  end

  defp current_group(_conn) do
    nil
  end

  # Create
  # ----------------------------------------------------------

  def new(conn, %{"group_id" => group_id, "shipment_id" => shipment_id}) do
    changeset = Shipments.change_route(%Route{})
    shipment = Shipments.get_shipment!(shipment_id) |> Ferry.Repo.preload(:routes)
    render(conn, "new.html", current_group: current_group(conn), group: group_id, shipment: shipment, changeset: changeset)
  end

  def create(conn, %{"group_id" => group_id, "shipment_id" => shipment_id, "route" => route_params} = params) do
    route_params = sanitize_checklist(params, route_params)

    case Shipments.create_route(route_params) do
      {:ok, _route} ->
        conn
        |> put_flash(:info, "Route created successfully.")
        |> redirect(to: Routes.group_shipment_path(conn, :show, group_id, shipment_id))
      {:error, %Ecto.Changeset{} = changeset} ->
        shipment = Shipments.get_shipment!(shipment_id) |> Ferry.Repo.preload(:routes)
        render(conn, "new.html", current_group: current_group(conn), group: group_id, shipment: shipment, changeset: changeset)
    end
  end

  # Update
  # ----------------------------------------------------------

  def edit(conn,  %{"group_id" => group_id, "shipment_id" => shipment_id, "id" => route_id}) do
    shipment = Shipments.get_shipment!(shipment_id) |> Ferry.Repo.preload(:routes)
    route = Shipments.get_route!(route_id)
    changeset = Shipments.change_route(route)
    render(conn, "edit.html", current_group: current_group(conn), group: group_id, shipment: shipment , route: route, changeset: changeset)
  end

  def update(conn,
    %{
      "group_id" => group_id,
      "shipment_id" => shipment_id,
      "id" => route_id,
      "route" => route_params
    } = params
  ) do
    route_params = sanitize_checklist(params, route_params)

    route = Shipments.get_route!(route_id)
    case Shipments.update_route(route, route_params) do
      {:ok, _route} ->
        conn
        |> put_flash(:info, "Route updated successfully.")
        |> redirect(to: Routes.group_shipment_path(conn, :show, group_id, shipment_id))
      {:error, %Ecto.Changeset{} = changeset} ->
        shipment = Shipments.get_shipment!(shipment_id) |> Ferry.Repo.preload(:routes)
        render(conn, "edit.html", current_group: current_group(conn), group: group_id, shipment: shipment, route: route, changeset: changeset)
    end
  end

  # Delete
  # ----------------------------------------------------------

  def delete(conn, %{"group_id" => group_id, "shipment_id" => shipment_id, "id" => route_id}) do
    route_id
    |> Shipments.get_route!
    |> Shipments.delete_route

    conn
    |> put_flash(:info, "Route deleted successfully.")
    |> redirect(to: Routes.group_shipment_path(conn, :show, group_id, shipment_id))
  end
end
