defmodule Ferry.Shipments.Shipment do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ferry.Locations.Address


  schema "shipments" do
    field :label, :string
    field :target_date_to_be_shipped, :string
    field :ready, :boolean
    field :shipment_underway, :boolean
    field :group_id, :integer
    field :sender_address, :string
    field :items, :string
    field :funding, :string
    field :reciever_address, :string
    field :reciever_group_id, :string
    timestamps()
  end

  @doc false
  def changeset(shipment, attrs) do
    shipment
    |> cast(attrs, [:group_id, :sender_address, :items, :funding, :reciever_address, :reciever_group_id,
        :shipment_underway, :ready, :target_date_to_be_shipped, :label ])
    |> validate_required(:label, [message: "We need to associate this shipment with a label"])
  end
end
