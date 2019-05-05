defmodule Ferry.Shipments.Route do
  use Ecto.Schema
  import Ecto.Changeset


  schema "routes" do
    field :label, :string
    field :address, :string
    field :date, :string
    field :groups, :string
    field :shipment_id, :string

    timestamps()
  end

  @doc false
  def changeset(route, attrs) do
    route
    |> cast(attrs, [:address, :date, :groups, :label, :shipment_id])
    |> validate_required([:address, :date, :groups])
  end
end
