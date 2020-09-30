defmodule FerryApi.Schema.Shipment do
  use Absinthe.Schema.Notation

  alias Ferry.Shipments

  import AbsintheErrorPayload.Payload
  alias FerryApi.Middleware
  alias Ferry.{Locations, Shipments}

  import_types(Absinthe.Type.Custom)

  object :shipment_queries do
    @desc "Get the total number of shipments in the system"
    field :count_shipments, :integer do
      resolve(&count_shipments/3)
    end

    @desc "Get all shipments"
    field :shipments, list_of(:shipment) do
      resolve(&list_shipments/3)
    end

    @desc "Get a single shipment"
    field :shipment, :shipment do
      arg(:id, non_null(:id))
      resolve(&get_shipment/3)
    end
  end

  input_object :shipment_input do
    field :pickup_address, non_null(:id)
    field :delivery_address, non_null(:id)
    field :status, non_null(:string)
    field :description, non_null(:string)
    field :transport_type, non_null(:string)
    field :available_from, non_null(:datetime)
    field :target_delivery, non_null(:datetime)
  end

  object :shipment_mutations do
    @desc "Create a shipment"
    field :create_shipment, type: :shipment_payload do
      arg(:shipment_input, non_null(:shipment_input))
      middleware(Middleware.RequireUser)
      resolve(&create_shipment/3)
      middleware(&build_payload/2)
    end

    @desc "Update a shipment"
    field :update_shipment, type: :shipment_payload do
      arg(:id, non_null(:id))
      arg(:shipment_input, non_null(:shipment_input))
      middleware(Middleware.RequireUser)
      resolve(&update_shipment/3)
      middleware(&build_payload/2)
    end

    @desc "Delete all shipments"
    field :delete_shipments, type: :boolean do
      middleware(Middleware.RequireUser)
      resolve(&delete_shipments/3)
    end
  end

  @shipment_not_found "shipment not found"

  @doc """
  Graphql resolver that returns the total number of shipments
  """
  @spec count_shipments(map(), map(), Absinthe.Resolution.t()) :: {:ok, non_neg_integer()}
  def count_shipments(_parent, _args, _resolution) do
    {:ok, Shipments.count_shipments()}
  end

  @doc """
  Graphql resolver that returns a collection of shipments
  """
  @spec list_shipments(map(), map(), Absinthe.Resolution.t()) ::
          {:ok, [map()]}
  def list_shipments(_parent, _args, _resolution) do
    {:ok, Shipments.list_shipments()}
  end

  @doc """
  Graphql resolver that returns a single mod value, given its id
  """
  @spec get_shipment(any, %{id: integer}, any) ::
          {:error, String.t()} | {:ok, map()}
  def get_shipment(_parent, %{id: id}, _resolution) do
    case Shipments.get_shipment(id) do
      nil ->
        {:error, @shipment_not_found}

      shipment ->
        {:ok, shipment}
    end
  end

  @doc """
  Graphql resolver that creates a shipment.

  We check that both the pickup and delivery addresses do exit,
  before trying to create the shipment
  """
  @spec create_shipment(
          any,
          %{shipment_input: map()},
          any
        ) :: {:error, Ecto.Changeset.t()} | {:ok, map()}
  def create_shipment(
        _parent,
        %{shipment_input: %{pickup_address: pickup, delivery_address: delivery} = attrs},
        _resolution
      ) do
    case Locations.get_address(pickup) do
      nil ->
        {:error, "pickup address not found"}

      pickup ->
        case Locations.get_address(delivery) do
          nil ->
            {:error, "delivery address not found"}

          delivery ->
            Shipments.create_shipment(
              pickup,
              delivery,
              Map.drop(attrs, [:pickup_address, :delivery_address])
            )
        end
    end
  end

  @doc """
  Graphql resolver that updates a shipment.

  We check that both the pickup and delivery addresses do exit,
  before trying to create the shipment
  """
  @spec update_shipment(
          any,
          %{id: integer(), shipment_input: map()},
          any
        ) :: {:error, String.t()} | {:error, Ecto.Changeset.t()} | {:ok, map()}
  def update_shipment(
        _parent,
        %{id: id, shipment_input: %{pickup_address: pickup, delivery_address: delivery} = attrs},
        _resolution
      ) do
    case Shipments.get_shipment(id) do
      nil ->
        {:error, @shipment_not_found}

      shipment ->
        case Locations.get_address(pickup) do
          nil ->
            {:error, "pickup address not found"}

          pickup ->
            case Locations.get_address(delivery) do
              nil ->
                {:error, "delivery address not found"}

              delivery ->
                Shipments.update_shipment(
                  shipment,
                  pickup,
                  delivery,
                  Map.drop(attrs, [:pickup_address, :delivery_address])
                )
            end
        end
    end
  end

  @doc """
  Graphql resolver that deletes all shipments
  """
  @spec delete_shipments(any, map(), any) :: {:ok, boolean()}
  def delete_shipments(_parent, _, _resolution) do
    {:ok, Shipments.delete_shipments()}
  end
end
