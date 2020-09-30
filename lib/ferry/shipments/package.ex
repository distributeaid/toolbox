defmodule Ferry.Shipments.Package do
  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{}

  alias Ferry.Shipments.Shipment

  schema "packages" do
    field :number, :integer
    field :type, :string
    field :contents, :string
    field :amount, :integer
    field :width, :integer
    field :height, :integer
    field :length, :integer
    field :stackable, :boolean
    field :dangerous_goods, :boolean

    belongs_to :shipment, Shipment
    timestamps()
  end

  @types [
    "pallet",
    "carton",
    "box"
  ]

  @required_fields [
    :number,
    :type,
    :contents,
    :amount,
    :width,
    :height,
    :length,
    :stackable,
    :dangerous_goods,
    :shipment_id
  ]

  @doc false
  def changeset(package, attrs) do
    package
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:type, @types)
  end
end
