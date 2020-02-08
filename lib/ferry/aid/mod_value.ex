defmodule Ferry.Aid.ModValue do
  use Ecto.Schema
#  import Ecto.Changeset

  alias Ferry.Aid.ListEntry
  alias Ferry.AidTaxonomy.Mod
  alias Ferry.AidTaxonomy.ModValueEctoType

  schema "aid__mod_values" do
    # NOTE: might want to define a custom ecto type to better support value polymorphism
    #       could use a virtual field to access mod.type in the custom type?
    #       https://hexdocs.pm/ecto/Ecto.Type.html#content
    #
    # Current mappings to :value are based on mod.type:
    #
    #   mod.type = :integer => ["1"]
    #   mod.type = :select => ["one of the values"]
    #   mod.type = :multi-select => ["a", "few", "values"]
    field :value, ModValueEctoType, default: nil

    belongs_to :mod, Mod
    belongs_to :entry, ListEntry, foreign_key: :entry_id

    timestamps()
  end
end
