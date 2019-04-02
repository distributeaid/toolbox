defmodule Ferry.Inventory.Mod do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ferry.Inventory.Stock


  schema "inventory_mods" do
    # NOTE: nil values for a field indicate that the associated stock falls into
    #       most/all categories, or the category is irrelevant.
    #
    #       EX:
    #         - gender: gender neutral
    #         - age: ageless
    #         - size: one size fits all
    #         - season:  year round

    field :gender, :string, defualt: nil # masc, fem
    field :age,    :string, defualt: nil # adult, child, baby
    field :size,   :string, defualt: nil # small, medium, large, x-large
    field :season, :string, defualt: nil # summer, winter

    has_many :stocks, Stock

    timestamps()
  end

  @doc false
  def changeset(mod, attrs) do
    mod
    |> cast(attrs, [:gender, :age, :size, :season])
  end
end
