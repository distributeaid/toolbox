defmodule FerryApi.Schema.NeedsListEntry do
  use Absinthe.Schema.Notation

  import AbsintheErrorPayload.Payload
  alias FerryApi.Middleware
  alias Ferry.Aid
  alias Ferry.AidTaxonomy

  object :needs_list_entry_queries do
    @desc "Returns a single entry"
    field :needs_list_entry, :needs_list_entry do
      arg(:id, non_null(:id))
      resolve(&entry/3)
    end
  end

  object :needs_list_entry_mutations do
    @desc "Create an entry"
    field :create_needs_list_entry, type: :needs_list_entry_payload do
      arg(:entry_input, non_null(:entry_input))
      middleware(Middleware.RequireUser)
      resolve(&create_entry/3)
      middleware(&build_payload/2)
    end

    @desc "Update a needs list"
    field :update_needs_list_entry, type: :needs_list_entry_payload do
      arg(:id, non_null(:id))
      arg(:entry_input, non_null(:entry_input))
      middleware(Middleware.RequireUser)
      resolve(&update_entry/3)
      middleware(&build_payload/2)
    end

    @desc "Delete a needs list"
    field :delete_needs_list_entry, type: :needs_list_entry_payload do
      arg(:id, non_null(:id))
      middleware(Middleware.RequireUser)
      resolve(&delete_entry/3)
      middleware(&build_payload/2)
    end
  end

  @item_not_found "item not found"
  @entry_not_found "entry not found"
  @list_not_found "list not found"

  @doc """
  Returns an entry given its id

  """
  @spec entry(any(), %{id: String.t()}, any()) ::
          {:ok, [map()]} | {:error, term()}
  def entry(_, %{id: id}, _) do
    with :not_found <- Aid.get_entry(id) do
      {:error, @entry_not_found}
    end
  end

  @doc """
  Graphql resolver that creates an entry, for the given list
  and item

  """
  @spec create_entry(
          any,
          %{entry_input: map()},
          any
        ) :: {:error, Ecto.Changeset.t()} | {:ok, map()}
  def create_entry(
        _parent,
        %{entry_input: %{list: list, item: item} = attrs},
        _resolution
      ) do
    case Aid.get_needs_list(list) do
      :not_found ->
        {:error, @list_not_found}

      {:ok, list} ->
        case AidTaxonomy.get_item(item) do
          nil ->
            {:error, @item_not_found}

          item ->
            Aid.create_entry(list, item, Map.drop(attrs, [:list, :item]))
        end
    end
  end

  @doc """
  Graphql resolver that updates an entry.

  For now, we are only allowed to change the amount
  """
  @spec update_entry(
          any,
          %{id: String.t(), entry_input: map()},
          any
        ) :: {:error, String.t()} | {:error, Ecto.Changeset.t()} | {:ok, map()}
  def update_entry(
        _parent,
        %{id: id, entry_input: attrs},
        _resolution
      ) do
    case Aid.get_entry(id) do
      :not_found ->
        {:error, @entry_not_found}

      {:ok, entry} ->
        Aid.update_entry(
          entry,
          attrs
        )
    end
  end

  @doc """
  Deletes a needs list

  """
  @spec delete_entry(any(), %{id: String.t()}, any()) ::
          {:ok, [map()]} | {:error, term()}
  def delete_entry(_, %{id: id}, _) do
    case Aid.get_entry(id) do
      :not_found ->
        {:error, @entry_not_found}

      {:ok, entry} ->
        Aid.delete_entry(entry)
    end
  end
end
