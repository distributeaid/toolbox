defmodule Ferry.Inventory.Packaging do
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  alias Ferry.Inventory.Stock
  alias Ferry.Inventory.Packaging.Photo


  schema "inventory_packaging" do
    field :count, :integer
    field :type, :string
    field :description, :string
    field :photo, Photo.Type

    has_one :stock, Stock

    timestamps()
  end

  @doc false
  def changeset(packaging, attrs) do
    packaging
    |> cast(attrs, [:count, :type, :description])
    |> validate_required([:count, :type])
    |> validate_number(:count, greater_than_or_equal_to: 0)

    |> cast_attachments(attrs, [:photo])
  end
end
