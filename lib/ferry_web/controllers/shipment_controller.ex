defmodule FerryWeb.ShipmentController do
  use FerryWeb, :controller

  alias Ferry.Shipments
  alias Ferry.Shipments.Shipment

  def index(%{assigns: %{current_user: %{group_id: group_id}}} = conn, _params) do
    shipments = Shipments.list_shipments()
    render(conn, "index.html", group: group_id, shipments: shipments)
  end

  def new(conn, _params) do
    changeset = Shipments.change_shipment(%Shipment{})
    render(conn, "new.html", group: conn.assigns.current_user.group_id, changeset: changeset)
  end

  def create(%{assigns: %{current_user: %{group_id: group_id}}} = conn, %{"shipment" => shipment_params}) do
    case Shipments.create_shipment(shipment_params) do
      {:ok, shipment} ->
        conn
        |> put_flash(:info, "Shipment created successfully.")
        |> redirect(to: group_shipment_path(conn, :show, group_id, shipment))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", group: group_id, changeset: changeset)
    end
  end

  def show(%{assigns: %{current_user: %{group_id: group_id}}} = conn, %{"id" => id}) do
    shipment = Shipments.get_shipment!(id)
    render(conn, "show.html", group: group_id, shipment: shipment)
  end

  def edit(%{assigns: %{current_user: %{group_id: group_id}}} = conn, %{"id" => id}) do
    shipment = Shipments.get_shipment!(id)
    changeset = Shipments.change_shipment(shipment)
    render(conn, "edit.html", group: group_id, shipment: shipment, changeset: changeset)
  end

  def update(%{assigns: %{current_user: %{group_id: group_id}}} = conn, %{"id" => id, "shipment" => shipment_params}) do
    shipment = Shipments.get_shipment!(id)

    case Shipments.update_shipment(shipment, shipment_params) do
      {:ok, shipment} ->
        conn
        |> put_flash(:info, "Shipment updated successfully.")
        |> redirect(to: group_shipment_path(conn, :show, group_id, shipment))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", group: group_id, shipment: shipment, changeset: changeset)
    end
  end

  def delete(%{assigns: %{current_user: %{group_id: group_id}}} = conn, %{"id" => id}) do
    shipment = Shipments.get_shipment!(id)
    {:ok, _shipment} = Shipments.delete_shipment(shipment)

    conn
    |> put_flash(:info, "Shipment deleted successfully.")
    |> redirect(to: group_shipment_path(conn, :index, group_id))
  end
end
