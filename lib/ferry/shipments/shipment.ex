defmodule Ferry.Shipments.Shipment do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ferry.Shipments.Route

  alias Ferry.Shipments.Role

  schema "shipments" do
    field :status, :string
    field :description, :string
    field :target_date, :string

    field :sender_address, :string
    field :receiver_address, :string

    field :transport_size, :string

    field :items, :string
    field :funding, :string

    # on_delete set in database via migration
    has_many :roles, Role
    # on_delete set in database via migration
    has_many :routes, Route

    timestamps()
  end

  @doc false
  def changeset(shipment, attrs) do
    shipment
    |> cast(attrs, [
      :status,
      :description,
      :target_date,
      :sender_address,
      :receiver_address,
      :transport_size,
      :items,
      :funding
    ])
    |> validate_required([:status, :target_date, :sender_address, :receiver_address])
    |> validate_inclusion(:status, [
      "planning",
      "ready",
      "underway",
      "received"
    ])
    |> validate_inclusion(:transport_size, [
      "",
      "Full Truck (13m / 40ft)",
      "Half Truck (13m / 40ft)",
      "Individual Pallets",
      "Van",
      "Car",
      "Shipping Container",
      "Other"
    ])
  end
end
