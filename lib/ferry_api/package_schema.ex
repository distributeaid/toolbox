defmodule FerryApi.Schema.Package do
  use Absinthe.Schema.Notation

  alias Ferry.Shipments

  import AbsintheErrorPayload.Payload
  alias FerryApi.Middleware
  alias Ferry.Shipments

  object :package_queries do
    @desc "Get a single package"
    field :package, :package do
      arg(:id, non_null(:id))
      resolve(&get_package/3)
    end
  end

  input_object :package_input do
    field :shipment, non_null(:id)
    field :number, :integer
    field :type, non_null(:string)
    field :contents, non_null(:string)
    field :amount, :integer
    field :width, :integer
    field :height, :integer
    field :length, :integer
    field :stackable, :boolean
    field :dangerous, :boolean
  end

  object :package_mutations do
    @desc "Create a package and add it to a shipment"
    field :create_package, type: :package_payload do
      arg(:package_input, non_null(:package_input))
      middleware(Middleware.RequireUser)
      resolve(&create_package/3)
      middleware(&build_payload/2)
    end

    @desc "Update an existing package"
    field :update_package, type: :package_payload do
      arg(:id, non_null(:id))
      arg(:package_input, non_null(:package_input))
      middleware(Middleware.RequireUser)
      resolve(&update_package/3)
      middleware(&build_payload/2)
    end

    @desc "Delete a package from a shipment"
    field :delete_package, type: :package_payload do
      arg(:id, non_null(:id))
      middleware(Middleware.RequireUser)
      resolve(&delete_package/3)
      middleware(&build_payload/2)
    end
  end

  @package_not_found "package not found"
  @shipment_not_found "shipment_not_found"

  @doc """
  Graphql resolver that returns a single package
  given its id
  """
  @spec get_package(any, %{id: integer}, any) ::
          {:error, String.t()} | {:ok, map()}
  def get_package(_parent, %{id: id}, _resolution) do
    case Shipments.get_package(id) do
      nil ->
        {:error, @package_not_found}

      package ->
        {:ok, package}
    end
  end

  @doc """
  Graphql resolver that creates a package.

  An error is returned if the associated hipment does not exist.
  """
  @spec create_package(
          any,
          %{package_input: map()},
          any
        ) :: {:error, Ecto.Changeset.t()} | {:ok, map()}
  def create_package(
        _parent,
        %{package_input: %{shipment: shipment_id} = attrs},
        _resolution
      ) do
    case Shipments.get_shipment(shipment_id) do
      nil ->
        {:error, @shipment_not_found}

      shipment ->
        Shipments.create_package(
          shipment,
          Map.drop(attrs, [:shipment])
        )
    end
  end

  @doc """
  Graphql resolver that updates a package.

  Returns an error if the package does not exist.

  This function also checks whether or not the associated shipment
  exists. This function can be used to move packages
  between shipments
  """
  @spec update_package(
          any,
          %{id: integer(), package_input: map()},
          any
        ) :: {:error, Ecto.Changeset.t()} | {:ok, map()}
  def update_package(
        _parent,
        %{id: id, package_input: %{shipment: shipment_id} = attrs},
        _resolution
      ) do
    case Shipments.get_package(id) do
      nil ->
        {:error, @package_not_found}

      package ->
        case Shipments.get_shipment(shipment_id) do
          nil ->
            {:error, @shipment_not_found}

          shipment ->
            Shipments.update_package(
              package,
              shipment,
              Map.drop(attrs, [:shipment])
            )
        end
    end
  end

  @doc """
  Graphql resolver that deletes a package

  """
  @spec delete_package(any, %{id: integer()}, any) ::
          {:error, String.t() | Ecto.Changeset.t()} | {:ok, map()}
  def delete_package(_parent, %{id: id}, _resolution) do
    case Shipments.get_package(id) do
      nil ->
        {:error, @package_not_found}

      package ->
        Shipments.delete_package(package)
    end
  end
end
