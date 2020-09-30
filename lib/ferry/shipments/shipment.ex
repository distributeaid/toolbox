defmodule Ferry.Shipments.Shipment do
  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{}

  alias Ferry.Locations.Address
  alias Ferry.Shipments.Package
  alias Ferry.Shipments.Role
  alias Ferry.Shipments.Route

  schema "shipments" do
    field :status, :string
    field :description, :string
    field :transport_type, :string
    field :available_from, :utc_datetime
    field :target_delivery, :utc_datetime

    belongs_to :pickup_address, Address
    belongs_to :delivery_address, Address

    # field :items, :string
    # field :funding, :string

    # on_delete set in database via migration
    has_many :roles, Role
    # on_delete set in database via migration
    has_many :routes, Route

    has_many :packages, Package

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
    :available_from,
    :target_delivery,
    :pickup_address_id,
    :delivery_address_id
  ]

  @doc false
  def changeset(shipment, attrs) do
    shipment
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:status, @statuses)
    |> validate_inclusion(:transport_type, @transport_types)
    |> cast_assoc(:roles)
    |> cast_assoc(:routes)
  end
end
