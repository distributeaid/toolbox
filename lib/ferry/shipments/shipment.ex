defmodule Ferry.Shipments.Shipment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "shipments" do
    field :sending_group_id, :string
    field :sender_address, :string
    field :items, :string
    field :funding, :integer
    field :reciever_address, :string
    field :reciever_group_id, :string
    timestamps()
  end

  @doc false
  def changeset(shipment, attrs) do
    shipment
    |> cast(attrs, [])
    |> validate_required([])
  end
end
