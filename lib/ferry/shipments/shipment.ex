defmodule Ferry.Shipments.Shipment do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ferry.Shipments.Route

  alias Ferry.Shipments.Role

  schema "shipments" do
    field :status, :string
    field :target_date_to_be_shipped, :string

    field :sender_address, :string
    field :receiver_address, :string

    field :items, :string
    field :funding, :string

    has_many :roles, Role # on_delete set in database via migration
    has_many :routes, Route # on_delete set in database via migration

    timestamps()
  end

  @doc false
  def changeset(shipment, attrs) do
    shipment
    |> cast(attrs, [
      :status,
      :target_date_to_be_shipped,

      :sender_address,
      :receiver_address,

      :items,
      :funding
    ])

    |> validate_required([:status, :target_date_to_be_shipped, :sender_address, :receiver_address])
    |> validate_inclusion(:status, ["planning", "ready", "underway", "received"])
  end
end
