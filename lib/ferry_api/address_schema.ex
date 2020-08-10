defmodule FerryApi.Schema.Address do
  use Absinthe.Schema.Notation
  alias FerryApi.Middleware
  import AbsintheErrorPayload.Payload

  input_object :address_input do
    field :group, :id
    field :label, :string
    field :street, :string
    field :city, :string
    field :province, :string
    field :country_code, :string
    field :postal_code, :string
  end

  object :address_queries do
    @desc "Get the # of addresses"
    field :count_addresses, :integer do
      resolve(&count_addresses/3)
    end

    @desc "Get all addresses"
    field :addresses, list_of(:address) do
      resolve(&list_addresses/3)
    end

    @desc "Get an address"
    field :address, :address do
      arg(:id, non_null(:id))
      resolve(&get_address/3)
    end
  end

  object :address_mutations do
    @desc "Create an address"
    field :create_address, type: :address_payload do
      arg(:address_input, non_null(:address_input))
      middleware(Middleware.RequireUser)
      resolve(&create_address/3)
      middleware(&build_payload/2)
    end

    @desc "Update a address"
    field :update_address, type: :address_payload do
      arg(:id, non_null(:id))
      arg(:address_input, non_null(:address_input))
      middleware(Middleware.RequireUser)
      resolve(&update_address/3)
      middleware(&build_payload/2)
    end

    @desc "Delete a address"
    field :delete_address, type: :address_payload do
      arg(:id, non_null(:id))
      middleware(Middleware.RequireUser)
      resolve(&delete_address/3)
      middleware(&build_payload/2)
    end
  end

  @group_not_found "group not found"
  @address_not_found "address not found"

  @doc """
  Graphql resolver that returns the total number of addresses
  """
  @spec count_addresses(map(), map(), Absinthe.Resolution.t()) :: {:ok, non_neg_integer()}
  def count_addresses(_parent, _args, _resolution) do
    {:ok, length(Ferry.Locations.list_addresses())}
  end

  @doc """
  Graphql resolver that returns a collection of addresses
  """
  @spec list_addresses(map(), map(), Absinthe.Resolution.t()) ::
          {:ok, [Ferry.Locations.Address.t()]}
  def list_addresses(_parent, _args, _resolution) do
    {:ok, Ferry.Locations.list_addresses()}
  end

  @doc """
  Graphql resolver that returns a single address, given its id
  """
  @spec get_address(map(), %{id: String.t()}, Absinthe.Resolution.t()) ::
          {:error, String.t()} | {:ok, Ferry.Locations.Address.t()}
  def get_address(_parent, %{id: id}, _resolution) do
    case Ferry.Locations.get_address(id) do
      nil ->
        {:error, @address_not_found}

      address ->
        {:ok, address}
    end
  end

  @doc """
  Graphql resolver that creates an address for a given group

  If the group does not exist, then an error is returned.
  """
  @spec create_address(
          any,
          %{address_input: map()},
          any
        ) :: {:error, Ecto.Changeset.t()} | {:ok, Ferry.Locations.Address.t()}
  def create_address(_parent, %{address_input: address_attrs}, _resolution) do
    case Ferry.Profiles.get_group(address_attrs.group) do
      nil ->
        {:error, @group_not_found}

      group ->
        Ferry.Locations.create_address(group, address_attrs)
    end
  end

  @doc """
  Graphql resolver that updates an existing address
  """
  @spec update_address(any(), %{address_input: any, id: String.t()}, any()) ::
          {:error, String.t() | Ecto.Changeset.t()} | {:ok, Ferry.Profiles.Project.t()}
  def update_address(_parent, %{id: id, address_input: address_attrs}, _resolution) do
    case Ferry.Locations.get_address(id) do
      nil ->
        {:error, @address_not_found}

      address ->
        Ferry.Locations.update_address(address, address_attrs)
    end
  end

  @doc """
  Graphql resolver that deletes an existing address
  """
  @spec delete_address(any, %{id: String.t()}, any) ::
          {:error, String.t() | Ecto.Changeset.t()} | {:ok, Ferry.Profiles.Project.t()}
  def delete_address(_parent, %{id: id}, _resolution) do
    case Ferry.Locations.get_address(id) do
      nil -> {:error, @address_not_found}
      address -> Ferry.Locations.delete_address(address)
    end
  end
end
