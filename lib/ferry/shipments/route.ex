defmodule Ferry.Shipments.Route do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ferry.Shipments.Shipment

  schema "routes" do
    field :label, :string, null: false
    field :address, :string
    field :date, :string
    field :groups, :string
    field :checklist, {:array, :string}
    belongs_to :shipment, Shipment # on_delete set in database via migration

    timestamps()
  end


  @doc false
  def changeset(route, attrs) do
    route
    |> cast(attrs, [:address, :date, :groups, :label, :shipment_id, :checklist])
    |> validate_required([:label, :shipment_id])
  end
end
