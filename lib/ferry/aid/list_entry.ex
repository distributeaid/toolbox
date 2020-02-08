defmodule Ferry.Aid.ListEntry do
  use Ecto.Schema
#  import Ecto.Changeset

  alias Ferry.Aid.AidList
  alias Ferry.Aid.ModValue
  alias Ferry.AidTaxonomy.Item

  schema "aid__list_entries" do
    field :amount, :integer, default: 0

    belongs_to :list, AidList, foreign_key: :list_id
    belongs_to :item, Item
    has_many :mod_values, ModValue, foreign_key: :entry_id

    timestamps()
  end
end
