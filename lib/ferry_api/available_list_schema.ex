defmodule FerryApi.Schema.AvailableList do
  use Absinthe.Schema.Notation

  import AbsintheErrorPayload.Payload
  alias FerryApi.Middleware
  alias Ferry.Aid
  alias Ferry.Locations

  object :available_list_queries do
    @desc "Returns a single available list"
    field :available_list, :available_list do
      arg(:id, non_null(:id))
      resolve(&available_list/3)
    end

    @desc "Returns all available lists at a given address"
    field :available_lists, list_of(:available_list) do
      arg(:at, non_null(:id))
      resolve(&available_lists/3)
    end
  end

  input_object :available_list_input do
    field :at, non_null(:id)
  end

  object :available_list_mutations do
    @desc "Create an available list"
    field :create_available_list, type: :available_list_payload do
      arg(:available_list_input, non_null(:available_list_input))
      middleware(Middleware.RequireUser)
      resolve(&create_available_list/3)
      middleware(&build_payload/2)
    end

    @desc "Delete an available list"
    field :delete_available_list, type: :available_list_payload do
      arg(:id, non_null(:id))
      middleware(Middleware.RequireUser)
      resolve(&delete_available_list/3)
      middleware(&build_payload/2)
    end
  end

  @address_not_found "address not found"
  @available_list_not_found "available list not found"

  @doc """
  Returns an availabe list given its id

  """
  @spec available_list(any(), %{id: integer()}, any()) ::
          {:ok, map()} | {:error, term()}
  def available_list(_, %{id: id}, _) do
    with :not_found <- Aid.get_available_list(id) do
      {:error, @available_list_not_found}
    end
  end

  @doc """
  Returns all available lists at a given address

  """
  @spec available_lists(any(), %{at: String.t()}, any()) ::
          {:ok, [map()]} | {:error, term()}
  def available_lists(_, %{at: address}, _) do
    case Locations.get_address(address) do
      nil ->
        {:error, @address_not_found}

      address ->
        {:ok, Aid.get_available_lists(address)}
    end
  end

  @doc """
  Graphql resolver that creates a available list.

  """
  @spec create_available_list(
          any,
          %{available_list_input: map()},
          any
        ) :: {:error, Ecto.Changeset.t()} | {:ok, map()}
  def create_available_list(
        _parent,
        %{available_list_input: %{at: address} = attrs},
        _resolution
      ) do
    case Locations.get_address(address) do
      nil ->
        {:error, @address_not_found}

      address ->
        Aid.create_available_list(address, Map.drop(attrs, [:at]))
    end
  end

  @doc """
  Deletes an available list

  """
  @spec delete_available_list(any(), %{id: integer()}, any()) ::
          {:ok, map()} | {:error, term()}
  def delete_available_list(_, %{id: id}, _) do
    case Aid.get_available_list(id) do
      :not_found ->
        {:error, @available_list_not_found}

      {:ok, available_list} ->
        Aid.delete_available_list(available_list)
    end
  end
end
