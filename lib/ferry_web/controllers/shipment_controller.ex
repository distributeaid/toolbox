defmodule FerryWeb.ShipmentController do
  use FerryWeb, :controller

  alias Ferry.Shipments
  alias Ferry.Shipments.Shipment

  def index(conn, _params) do
    shipments = Shipments.list_shipments()
    render(conn, "index.html", shipments: shipments)
  end

  def new(conn, _params) do
    changeset = Shipments.change_shipment(%Shipment{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"shipment" => shipment_params}) do
    case Shipments.create_shipment(shipment_params) do
      {:ok, shipment} ->
        conn
        |> put_flash(:info, "Shipment created successfully.")
        |> redirect(to: group_shipment_path(conn, :show, 1, shipment))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    shipment = Shipments.get_shipment!(id)
    render(conn, "show.html", shipment: shipment)
  end

  def edit(conn, %{"id" => id}) do
    shipment = Shipments.get_shipment!(id)
    changeset = Shipments.change_shipment(shipment)
    render(conn, "edit.html", shipment: shipment, changeset: changeset)
  end

  def update(conn, %{"id" => id, "shipment" => shipment_params}) do
    shipment = Shipments.get_shipment!(id)

    case Shipments.update_shipment(shipment, shipment_params) do
      {:ok, shipment} ->
        conn
        |> put_flash(:info, "Shipment updated successfully.")
        |> redirect(to: group_shipment_path(conn, :show, 1, shipment))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", shipment: shipment, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    shipment = Shipments.get_shipment!(id)
    {:ok, _shipment} = Shipments.delete_shipment(shipment)

    conn
    |> put_flash(:info, "Shipment deleted successfully.")
    |> redirect(to: group_shipment_path(conn, :index, 1))
  end
end
