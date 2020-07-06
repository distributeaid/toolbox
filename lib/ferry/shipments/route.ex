defmodule Ferry.Shipments.Route do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ferry.Shipments.Shipment

  schema "routes" do
    field :type, :string, null: false
    field :address, :string
    field :date, :date

    field :groups, :string
    field :checklist, {:array, :string}

    # on_delete set in database via migration
    belongs_to :shipment, Shipment

    timestamps()
  end

  @doc false
  def changeset(route, attrs) do
    route
    |> cast(attrs, [:type, :address, :date, :groups, :checklist, :shipment_id])
    |> validate_required([:type, :address, :date, :shipment_id])
  end
end
