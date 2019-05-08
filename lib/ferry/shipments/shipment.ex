defmodule Ferry.Shipments.Shipment do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ferry.Shipments.Role

  schema "shipments" do
    field :label, :string
    field :target_date_to_be_shipped, :string
    field :status, :string
    field :sender_address, :string
    field :items, :string
    field :funding, :string
    field :receiver_address, :string

    has_many :roles, Role # on_delete set in database via migration

    timestamps()
  end

  @doc false
  def changeset(shipment, attrs) do
    shipment
    |> cast(attrs, [:sender_address, :items, :funding, :receiver_address,
        :status, :target_date_to_be_shipped, :label ])
    |> validate_required(:label, [message: "We need to associate this shipment with a label"])
    |> validate_inclusion(:status, ["planning_shipment", "ready", "shipment_underway", "shipment_received"])
  end
end
