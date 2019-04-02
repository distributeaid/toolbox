defmodule Ferry.Inventory.Category do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ferry.Inventory.Item


  schema "inventory_categories" do
    field :name, :string

    has_many :items, Item

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, max: 255)
  end
end
