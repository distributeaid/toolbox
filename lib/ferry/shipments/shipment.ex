defmodule Ferry.Shipments.Shipment do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ferry.Shipments.Route
  alias Ferry.Shipments.Role

  schema "shipments" do
    field :status, :string
    field :description, :string
    field :transport_type, :string
    field :pickup_address, :string
    field :delivery_address, :string
    field :available_from, :utc_datetime
    field :target_delivery, :utc_datetime

    # field :target_date, :string

    # field :items, :string
    # field :funding, :string

    # on_delete set in database via migration
    has_many :roles, Role
    # on_delete set in database via migration
    has_many :routes, Route

    timestamps()
  end

  @transport_types [
    "full_truck",
    "half_truck",
    "pallets",
    "van",
    "car",
    "container",
    "other",
    "air",
    "sea",
    "truck"
  ]

  @statuses [
    "planning",
    "ready",
    "underway",
    "received"
  ]

  @required_fields [
    :status,
    :description,
    :transport_type,
    :pickup_address,
    :delivery_address,
    :available_from,
    :target_delivery
  ]

  @doc false
  def changeset(shipment, attrs) do
    shipment
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:status, @statuses)
    |> validate_inclusion(:transport_type, @transport_types)
  end
end
