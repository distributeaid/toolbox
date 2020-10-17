defmodule Ferry.Aid.EntryModValue do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ferry.AidTaxonomy.ModValue
  alias Ferry.Aid.Entry
  alias Ferry.Aid

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
    |> validate_mod_value_in_mods()
    |> foreign_key_constraint(:entry_id)
    |> foreign_key_constraint(:mod_value_id)
    |> unique_constraint([:entry, :mod_value],
      name: "distinct_mod_values_per_list_entry",
      message: "already exists"
    )
  end

  @doc """
  Ensures the mod_value we are trying to add actually belongs to one of the
  mods of the item to which the entry relates.

  We also want to ensure we allow the right number of values:

  * If the mod is of type `multi-select`, then more than one value is allowed.
  * Otherwise, at most one value is allowed
  """
  @spec validate_mod_value_in_mods(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate_mod_value_in_mods(changeset) do
    {:ok, entry} = Aid.get_entry(changeset.changes.entry_id, item_preload: :with_mod_values)

    changeset
    |> validate_with(entry, &mod_value_in_mods?/2, "must be within the entry's item mod values")
    |> validate_with(entry, &mod_value_has_right_cardinality?/2, "has too many values")
  end

  # Generic function so that we can easily plug new validation
  # rules in the future
  defp validate_with(changeset, entry, fun, message) do
    mod_value_id = changeset.changes.mod_value_id

    case fun.(entry, mod_value_id) do
      true ->
        changeset

      false ->
        add_error(changeset, :mod_value, message)
    end
  end

  # Checks whether the given mod_value id is known by the mods
  # associated to the linked item
  defp mod_value_in_mods?(%Entry{} = entry, mod_value_id) do
    entry.item.mods
    |> Enum.flat_map(fn %{values: values} -> values end)
    |> Enum.reduce_while(false, fn
      %{id: ^mod_value_id}, _ -> {:halt, true}
      _, _ -> {:cont, false}
    end)
  end

  # Checks whether it is legal to add a new mod value to
  # the entry depending on the kind of mod (select vs multi-select)
  # If the mod is of type select, and a mod value for the same
  # mod already exists, then we should not allow
  # a new value
  #
  # *Note*: this implementation is not free from potential
  # race conditions. It would probably be safer to encode
  # this constraint as a postgres function and let the database
  # ensure data consistency
  defp mod_value_has_right_cardinality?(entry, mod_value_id) do
    case entry.mod_values do
      [] ->
        # for the moment, the entry has no mod values
        # so we can add a new one no matter its type
        true

      _ ->
        # There are some values already, so we need
        # to inspect further
        mod = mod_for(entry, mod_value_id)

        case mod.type do
          "multi-select" ->
            # The mod is of type multi-select therefore
            # it allows many values for the same mod
            true

          _ ->
            # The mod is singe-valued, so we need to make
            # sure we currently don't have values for that mod
            mod_values_count = mod_values_count_by_mod(entry)
            Map.get(mod_values_count, mod.id, 0) == 0
        end
    end
  end

  # Returns the parent mod for the given mod value id
  defp mod_for(entry, mod_value_id) do
    entry.item.mods
    |> Enum.reduce(%{}, fn %{values: values} = mod, acc ->
      Enum.reduce(values, acc, fn %{id: id}, acc2 ->
        Map.put(acc2, id, mod)
      end)
    end)
    |> Map.get(mod_value_id)
    |> case do
      nil ->
        raise "Unable to find mod for mod value #{mod_value_id} in: #{inspect(entry.item.mods)}"

      mod ->
        mod
    end
  end

  # Counts mod values by mod
  defp mod_values_count_by_mod(entry) do
    entry.mod_values
    |> Enum.reduce(%{}, fn %{mod_value: %ModValue{mod: entry_mod_value_mod}}, acc ->
      mod_id = entry_mod_value_mod.id
      count = Map.get(acc, mod_id, 0)
      Map.put(acc, mod_id, count + 1)
    end)
  end
end
