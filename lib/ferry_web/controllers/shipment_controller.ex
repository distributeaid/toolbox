defmodule FerryWeb.ShipmentController do
  use FerryWeb, :controller

  alias Ferry.Shipments
  alias Ferry.Shipments.Shipment
  alias Ferry.Shipments.Role
  alias Ferry.Profiles

  defp current_group(_conn = %{assigns: %{current_user: %{group_id: group_id}}}) do
    Profiles.get_group!(group_id)
  end

  def index(conn, _params) do
    group = current_group(conn)
    shipments = Shipments.list_shipments(group)
    render(conn, "index.html", group: group, shipments: shipments)
  end

  def new(conn, _params) do
    group = current_group(conn)
    changeset = Shipments.change_shipment(%Shipment{
      roles: [%Role{group_id: group.id}]
    })
    render(conn, "new.html", group: group, changeset: changeset)
  end

  def create(conn, %{"shipment" => shipment_params}) do
    group = current_group(conn)
    shipment_params = Map.put(shipment_params, "group_id", group.id)
    %{"new_route" => add_route? } = shipment_params

    case Shipments.create_shipment(shipment_params) do
      {:ok, shipment} ->
        case add_route? do
          "true" ->
            changeset = Shipments.change_route(%Shipments.Route{})
            shipment = Ferry.Repo.preload(shipment, :routes)
            render( conn,FerryWeb.RouteView, "new.html", group: group, shipment: shipment, changeset: changeset)
          "false" ->
            redirect(conn, to: group_shipment_path(conn, :show, group.id, shipment))
        end
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", group: group, changeset: changeset)
    end
  end

  # TODO: needs to throw an error if the group doesn't have an assigned role in the shipment
  #       currently provides edit access to any shipment
  #       we should probably check this more generally, since our auth system
  #       only compares the logged in group to the group specified in the
  #       route, but doesn't check that the group in the route has access to
  #       a specific sub-resource
  def show(conn, %{"id" => id} = _params) do
    group = current_group(conn)
    shipment = Shipments.get_shipment!(id)
    routes = Shipments.list_routes(shipment)
    render(conn, "show.html", group: group, shipment: shipment, routes: routes)
  end

  def edit(conn, %{"id" => id}) do
    #NEED TO MAKE SOME OF the db columns immutable?
    group = current_group(conn)
    shipment = Shipments.get_shipment!(id)
    changeset = Shipments.change_shipment(shipment)
    render(conn, "edit.html", group: group, shipment: shipment, changeset: changeset)
  end

  def update(conn, %{"id" => id, "shipment" => shipment_params}) do
    group = current_group(conn)
    shipment = Shipments.get_shipment!(id)

    case Shipments.update_shipment(shipment, shipment_params) do
      {:ok, shipment} ->
        conn
        |> put_flash(:info, "Shipment updated successfully.")
        |> redirect(to: group_shipment_path(conn, :show, group, shipment))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", group: group, shipment: shipment, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    group = current_group(conn)
    shipment = Shipments.get_shipment!(id)
    {:ok, _shipment} = Shipments.delete_shipment(shipment)

    conn
    |> put_flash(:info, "Shipment deleted successfully.")
    |> redirect(to: group_shipment_path(conn, :index, group))
  end
end
