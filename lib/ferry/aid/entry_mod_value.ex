defmodule Ferry.Aid.EntryModValue do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ferry.AidTaxonomy.ModValue
  alias Ferry.Aid.Entry

  @type t() :: %__MODULE__{}

  schema "aid__list_entries__mod_values" do
    belongs_to :entry, Entry, foreign_key: :entry_id
    belongs_to :mod_value, ModValue, foreign_key: :mod_value_id
    timestamps()
  end

  @required_fields ~w(entry_id mod_value_id)a

  @doc """
  Defines a changeset for a entry vs mod value relationship

  Verifies integrity with both list entries and mod values tables, and also
  ensures a mod value is added to the same entry only once. Returns constraints errors
  as changeset errors so that they can be properly communicated back
  to the client
  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(entry_mod_value, params) do
    entry_mod_value
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:entry_id)
    |> foreign_key_constraint(:mod_value_id)
    |> unique_constraint([:entry, :mod_value],
      name: "distinct_mod_values_per_list_entry",
      message: "already exists"
    )
  end
end
