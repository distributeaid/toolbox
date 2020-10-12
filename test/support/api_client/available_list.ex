defmodule Ferry.ApiClient.AvailableList do
  @moduledoc """
  Helper module that provides with a convenience GraphQL client api
  for dealing with Available Lists in tests.
  """

  import Ferry.ApiClient.GraphCase

  @doc """
  Run a GraphQL mutation that creates an available list
  """
  @spec create_available_list(Plug.Conn.t(), map()) :: map()
  def create_available_list(conn, attrs) do
    graphql(conn, """
      mutation {
        createAvailableList(
          availableListInput: {
            address: "#{attrs.project}",
          }
        ) {
          successful,
          messages {
            field
            message
          },
          result {
            id,
            address {
              id,
              group {
                id,
                name
              }
            }
            entries {
              id,
              item {
                id
              },
              amount
            }
          }
        }
      }
    """)
  end

  @doc """
  Run a GraphQL mutation that creates an available list
  """
  @spec update_available_list(Plug.Conn.t(), map()) :: map()
  def update_available_list(conn, attrs) do
    graphql(conn, """
      mutation {
        updateAvailableList(
            id: "#{attrs.id}",
            availableListInput: {
              address: "#{attrs.address}"
            }
          ) {
            successful,
            messages {
              field
              message
            },
            result {
              id,
              address {
                id,
                group {
                  id,
                  name
                }
              }
              entries {
                id,
                item {
                  id
                },
                amount
              }
            }
          }
        }
    """)
  end

  @doc """
  Run a GraphQL mutation that deletes an available list, given its id
  """
  @spec delete_available_list(Plug.Conn.t(), String.t()) :: map()
  def delete_available_list(conn, id) do
    graphql(conn, """
      mutation {
        deleteAvailableList(id: "#{id}") {
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
