defmodule Ferry.Inventory.Item do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ferry.Inventory.{Category, Stock}


  schema "inventory_items" do
    field :name, :string
    field :count, :integer, virtual: true

    belongs_to :category, Category
    has_many :stocks, Stock

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, max: 255)

    |> put_assoc(:category, attrs["category"])
    |> assoc_constraint(:category)
  end
end
