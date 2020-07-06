defmodule Ferry.Aid.ModValue do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ferry.Aid.Entry
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
    belongs_to :entry, Entry, foreign_key: :entry_id

    timestamps()
  end

  # NOTE: Expected to be set via a cast_assoc call in the Entry changesets.
  #
  # TODO: Identify if we're inserting, updating, or deleting the ModValue and
  #       customize the validation.
  #       EX: Shouldn't be able to update the :mod or :entry fields.
  def changeset(mod_value, params \\ %{}) do
    mod_value
    |> cast(params, [:value, :mod_id, :entry_id])
    |> validate_required([:value])
    |> assoc_constraint(:mod)
    |> assoc_constraint(:entry)
    |> unique_constraint(:value,
      name: "aid__mod_values_entry_id_mod_id_index",
      message: "already set"
    )
  end
end
