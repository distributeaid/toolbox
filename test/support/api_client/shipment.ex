defmodule Ferry.ApiClient.Shipment do
  @moduledoc """
  Helper module that provides with a convenience GraphQL client api
  for dealing with Shipments in tests.
  """

  import Ferry.ApiClient.GraphCase

  @doc """
  Run a GraphQL query that returns a list of shipments
  """
  @spec get_shipments(Plug.Conn.t()) :: map()
  def get_shipments(conn) do
    graphql(conn, """
    {
      shipments {
        id,
        pickup_address {
          id
        },
        delivery_address {
          id
        },
        status,
        description,
        transportType,
        availableFrom,
        targetDelivery,
        packages {
          id,
          number,
          type,
          contents,
          dangerous
        }
      }
    }
    """)
  end

  @doc """
  Run a GraphQL query that retuns a shipment given its
  id
  """
  @spec get_shipment(Plug.Conn.t(), String.t()) :: map()
  def get_shipment(conn, id) do
    graphql(conn, """
    {
      shipment(id: "#{id}") {
        id,
        pickupAddress {
          id
        },
        deliveryAddress {
          id
        },
        status,
        description,
        transportType,
        availableFrom,
        targetDelivery,
        packages {
          id,
          number,
          type,
          contents,
          dangerous
        }
      }
    }
    """)
  end

  @doc """
  Run a GraphQL mutation that creates a shipment
  """
  @spec create_shipment(Plug.Conn.t(), map()) :: map()
  def create_shipment(conn, attrs) do
    available_from = (attrs[:available_from] || DateTime.utc_now()) |> DateTime.to_iso8601()
    target_delivery = (attrs[:target_delivery] || DateTime.utc_now()) |> DateTime.to_iso8601()
    status = attrs[:status] || "planning"

    graphql(conn, """
      mutation {
        createShipment(
          shipmentInput: {
            pickupAddress: "#{attrs.pickup}",
            deliveryAddress: "#{attrs.delivery}",
            status: "#{status}",
            description: "a shipment",
            transportType: "pallets",
            availableFrom: "#{available_from}",
            targetDelivery: "#{target_delivery}"
          }
        ){
          successful,
          messages { field, message },
          result {
            id,
            pickupAddress {
              id
            },
            deliveryAddress {
              id
            },
            status,
            description,
            transportType,
            availableFrom,
            targetDelivery
          }
        }
      }
    """)
  end

  @doc """
  Run a GraphQL mutation that updates a shipment
  """
  @spec update_shipment(Plug.Conn.t(), map()) :: map()
  def update_shipment(conn, attrs) do
    available_from = (attrs[:available_from] || DateTime.utc_now()) |> DateTime.to_iso8601()
    target_delivery = (attrs[:target_delivery] || DateTime.utc_now()) |> DateTime.to_iso8601()
    status = attrs[:status] || "planning"

    graphql(conn, """
      mutation {
        updateShipment(
          id: "#{attrs.id}",
          shipmentInput: {
            pickupAddress: "#{attrs.pickup}",
            deliveryAddress: "#{attrs.delivery}",
            status: "#{status}",
            description: "a shipment",
            transportType: "pallets",
            availableFrom: "#{available_from}",
            targetDelivery: "#{target_delivery}"
          }
        ){
          successful,
          messages { field, message },
          result {
            id,
            pickupAddress {
              id
            },
            deliveryAddress {
              id
            },
            status,
            description,
            transportType,
            availableFrom,
            targetDelivery
          }
        }
      }
    """)
  end

  @doc """
  Run a GraphQL mutation that deletes a shipment, given its id
  """
  @spec delete_shipment(Plug.Conn.t(), String.t()) :: map()
  def delete_shipment(conn, id) do
    graphql(conn, """
      mutation {
        deleteShipment(id: "#{id}") {
          successful,
          messages {
            field
            message
          },
          result {
            id
          }
        }
      }
    """)
  end
end
