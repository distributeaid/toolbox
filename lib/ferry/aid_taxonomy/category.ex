defmodule Ferry.AidTaxonomy.Category do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  alias Ferry.AidTaxonomy.Item
  alias Ferry.Utils

  schema "aid__item_categories" do
    field :name, :string

    has_many :items, Item, foreign_key: :category_id

    timestamps()
  end

  def changeset(category, params \\ %{}) do
    category
    |> cast(params, [:name])
    |> validate_required([:name])
    # TODO test error message and possibly add our own "should be %{count} character(s)"
    |> validate_length(:name, min: 2, max: 32)
    |> foreign_key_constraint(:entries, name: "aid__list_entries_item_id_fkey")
    |> unique_constraint(:name, message: "already exists")
    |> Utils.put_normalized_name()
  end
end
