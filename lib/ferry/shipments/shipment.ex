defmodule Ferry.Shipments.Shipment do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ferry.Shipments.Route

  schema "shipments" do
    field :label, :string
    field :target_date_to_be_shipped, :string
    field :status, :string
    field :group_id, :integer
    field :sender_address, :string
    field :items, :string
    field :funding, :string
    field :receiver_address, :string
    field :receiver_group_id, :string
    has_many :routes, Route

    timestamps()
  end

  @doc false
  def changeset(shipment, attrs) do
    shipment
    |> cast(attrs, [:group_id, :sender_address, :items, :funding, :receiver_address, :receiver_group_id,
        :status, :target_date_to_be_shipped, :label])
    |> cast_assoc(:routes)
    |> validate_required(:label, [message: "We need to associate this shipment with a label"])
    |> validate_inclusion(:status, ["planning_shipment", "ready", "shipment_underway", "shipment_received"])
  end
end
