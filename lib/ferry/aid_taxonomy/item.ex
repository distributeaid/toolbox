defmodule Ferry.AidTaxonomy.Item do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ferry.AidTaxonomy.Category
  alias Ferry.AidTaxonomy.Mod

  schema "aid__items" do
    field :name, :string

    belongs_to :category, Category, foreign_key: :category_id

    # TODO: probably want to setup a schema for the join table with
    # has_many / belongs_to on each side, to provide flexibility if we ever need
    # metadata on the relationship
    many_to_many :mods, Mod, unique: true, join_through: "aid__items__mods", on_replace: :delete

    timestamps()
  end

  def changeset(item, params \\ %{}) do
    item
    |> cast(params, [:name])

    |> validate_required([:name])
    # TODO test error message and possibly add our own "should be %{count} character(s)"
    |> validate_length(:name, min: 2, max: 32)

    |> foreign_key_constraint(:entries, name: "aid__list_entries_item_id_fkey")
    |> unique_constraint(:name, name: "aid__items_category_id_name_index", message: "already exists")
  end
end
