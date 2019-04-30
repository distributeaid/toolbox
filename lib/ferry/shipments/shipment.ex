defmodule Ferry.Shipments.Shipment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "shipments" do
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
    |> cast(attrs, [:group_id, :sender_address, :items, :funding, :reciever_address, :reciever_group_id])
    |> validate_required(:group_id, [message: "Cannot be Empty"])
    |> validate_required(:sender_address, [message: "We need the address supplies will be sent from"])
    |> validate_required(:items, [message: "We need the items that will be sent"])
    |> validate_required(:funding, [message: "How will this shipment be funded?"])
    |> validate_required(:reciever_address, [message: "Where are the supplies being shipped?"])
    |> validate_required(:reciever_group_id, [message: "If the group is not setup yet, provide an email address"])
  end
end
