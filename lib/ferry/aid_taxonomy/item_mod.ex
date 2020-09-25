defmodule Ferry.AidTaxonomy.ItemMod do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ferry.AidTaxonomy.{Item, Mod}

  @type t :: %__MODULE__{}

  schema "aid__items__mods" do
    belongs_to :item, Item, foreign_key: :item_id
    belongs_to :mod, Mod, foreign_key: :mod_id
    timestamps()
  end

  @required_fields ~w(item_id mod_id)a

  @doc """
  Defines a changeset for a mod item relationship

  Verifies integrity with both mod and items tables, and also
  ensures a mod is added to an item only once. Returns constraints errors
  as changeset errors so that they can be properly communicated back
  to the client
  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(item_mod, params) do
    item_mod
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:item_id)
    |> foreign_key_constraint(:mod_id)
    |> unique_constraint([:mod, :item],
      name: "aid__items__mods_item_id_mod_id_index",
      message: "already exists"
    )
  end
end
