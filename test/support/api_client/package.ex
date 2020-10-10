defmodule Ferry.ApiClient.Package do
  @moduledoc """
  Helper module that provides with a convenience GraphQL client api
  for dealing with Shipments in tests.
  """

  import Ferry.ApiClient.GraphCase

  @doc """
  Run a GraphQL query that retuns a package given its
  id
  """
  @spec get_package(Plug.Conn.t(), String.t()) :: map()
  def get_package(conn, id) do
    graphql(conn, """
    {
      package(id: "#{id}") {
        id,
        shipment {
          id
        },
        number,
        type,
        contents,
        amount,
        width,
        height,
        length,
        stackable,
        dangerous
      }
    }
    """)
  end

  @doc """
  Run a GraphQL mutation that creates a package
  under a given shipment
  """
  @spec create_package(Plug.Conn.t(), map()) :: map()
  def create_package(conn, attrs) do
    graphql(conn, """
      mutation {
        createPackage(
          packageInput: {
            shipment: "#{attrs.shipment}",
            number: #{attrs[:number] || 1},
            type: "#{attrs[:type] || "pallet"}",
            contents: "#{attrs[:contents] || "some goods"}",
            amount: #{attrs[:amount] || 1},
            width: #{attrs[:width] || 100},
            height: #{attrs[:height] || 100},
            length: #{attrs[:length] || 100},
            stackable: #{attrs[:stackable] || true},
            dangerous: #{attrs[:dangerous] || false}
          }
        ) {
          successful,
          messages { field, message },
          result {
            id,
            shipment {
              id
            },
            number,
            type,
            contents,
            amount,
            width,
            height,
            length,
            stackable,
            dangerous
          }
        }
      }
    """)
  end

  @doc """
  Run a GraphQL mutation that updates a package
  """
  @spec update_package(Plug.Conn.t(), map()) :: map()
  def update_package(conn, attrs) do
    graphql(conn, """
      mutation {
        updateShipment(
          id: "#{attrs.id}",
          packageInput: {
            shipment: "#{attrs.shipment}",
            number: #{attrs[:number] || 1},
            type: "#{attrs[:type] || ""}",
            contents: "#{attrs[:contents] || "some goods"}",
            amount: #{attrs[:amount] || 1},
            width: #{attrs[:width] || 100},
            height: #{attrs[:height] || 100},
            length: #{attrs[:length] || 100},
            stackable: #{attrs[:stackable] || true},
            dangerous: #{attrs[:dangerous] || false}
          }
        ){
          successful,
          messages { field, message },
          result {
            id,
            shipment {
              id
            },
            number,
            type,
            contents,
            amount,
            width,
            height,
            length,
            stackable,
            dangerous
          }
        }
      }
    """)
  end

  @doc """
  Run a GraphQL mutation that deletes a package, given its id
  """
  @spec delete_package(Plug.Conn.t(), String.t()) :: map()
  def delete_package(conn, id) do
    graphql(conn, """
      mutation {
        deletePackage(id: "#{id}") {
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
