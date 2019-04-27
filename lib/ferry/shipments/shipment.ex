defmodule Ferry.Shipments.Shipment do
  use Ecto.Schema
  import Ecto.Changeset


  schema "shipments" do

    timestamps()
  end

  @doc false
  def changeset(shipment, attrs) do
    shipment
    |> cast(attrs, [])
    |> validate_required([])
  end
end
