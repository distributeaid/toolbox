defmodule FerryApi.Schema.NeedsListEntryModValue do
  use Absinthe.Schema.Notation

  import AbsintheErrorPayload.Payload
  alias FerryApi.Middleware
  alias Ferry.Aid
  alias Ferry.AidTaxonomy

  object :needs_list_entry_mod_value_mutations do
    @desc "Add an existing mod value to an existing needs list entry"
    field :add_mod_value_to_needs_list_entry, type: :needs_list_entry_payload do
      arg(:entry_mod_value_input, non_null(:entry_mod_value_input))
      middleware(Middleware.RequireUser)
      resolve(&add_mod_value_to_list_entry/3)
      middleware(&build_payload/2)
    end

    @desc "Remove an existing mod value from an existing needs list entry"
    field :remove_mod_value_from_needs_list_entry, type: :needs_list_entry_payload do
      arg(:entry_mod_value_input, non_null(:entry_mod_value_input))
      middleware(Middleware.RequireUser)
      resolve(&remove_mod_value_from_list_entry/3)
      middleware(&build_payload/2)
    end
  end

  @entry_not_found "entry not found"
  @mod_value_not_found "mod value not found"

  @doc """
  Graphql resolver that adds a new mod value to an existing
  needs list entry
  """
  @spec add_mod_value_to_list_entry(
          any,
          %{entry_mod_value_input: map()},
          any
        ) :: {:error, Ecto.Changeset.t()} | {:ok, map()}
  def add_mod_value_to_list_entry(
        _parent,
        %{entry_mod_value_input: %{entry: entry, mod_value: mod_value}},
        _resolution
      ) do
    case AidTaxonomy.get_mod_value(mod_value) do
      nil ->
        {:error, @mod_value_not_found}

      mod_value ->
        case Aid.get_entry(entry, item_preload: :with_mod_values) do
          :not_found ->
            {:error, @entry_not_found}

          {:ok, entry} ->
            with :ok <- Aid.add_mod_value_to_entry(mod_value, entry) do
              # We need to return the entry as an needs list entry
              # and it has to be linked to its needs list, for completeness
              # with other apis. Since we have this convention
              # already implemented in the needs list schema module, we can
              # simply reuse it.
              FerryApi.Schema.NeedsListEntry.entry(nil, %{id: entry.id}, nil)
            end
        end
    end
  end

  @doc """
  Graphql resolver that removes an existing mod value from an existing
  needs list entry
  """
  @spec remove_mod_value_from_list_entry(
          any,
          %{entry_mod_value_input: map()},
          any
        ) :: {:error, Ecto.Changeset.t()} | {:ok, map()}
  def remove_mod_value_from_list_entry(
        _parent,
        %{entry_mod_value_input: %{entry: entry, mod_value: mod_value}},
        _resolution
      ) do
    case AidTaxonomy.get_mod_value(mod_value) do
      nil ->
        {:error, @mod_value_not_found}

      mod_value ->
        case Aid.get_entry(entry, item_preload: :with_mod_values) do
          :not_found ->
            {:error, @entry_not_found}

          {:ok, entry} ->
            with :ok <- Aid.remove_mod_value_from_entry(mod_value, entry) do
              # We need to return the entry as an needs list entry
              # and it has to be linked to its needs list, for completeness
              # with other apis. Since we have this convention
              # already implemented in the needs list schema module, we can
              # simply reuse it.
              FerryApi.Schema.NeedsListEntry.entry(nil, %{id: entry.id}, nil)
            end
        end
    end
  end
end
