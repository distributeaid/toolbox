defmodule Ferry.ApiClient.AvailableList do
  @moduledoc """
  Helper module that provides with a convenience GraphQL client api
  for dealing with Available Lists in tests.
  """

  import Ferry.ApiClient.GraphCase

  @doc """
  GraphQL query that returns all available lists for a given address
  """
  @spec get_available_lists(Plug.Conn.t(), map()) :: map()
  def get_available_lists(conn, attrs) do
    graphql(conn, """
    {
      availableLists(at: "#{attrs.address}") {
        id,
        at {
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
    """)
  end

  @doc """
  GraphQL query that returns an available list given its id
  """
  @spec get_available_list(Plug.Conn.t(), String.t()) :: map()
  def get_available_list(conn, id) do
    graphql(conn, """
    {
      availableList(id: "#{id}") {
        id,
        at {
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
    """)
  end

  @doc """
  Run a GraphQL mutation that creates an available list
  """
  @spec create_available_list(Plug.Conn.t(), map()) :: map()
  def create_available_list(conn, attrs) do
    graphql(conn, """
      mutation {
        createAvailableList(
          availableListInput: {
            at: "#{attrs.address}",
          }
        ) {
          successful,
          messages {
            field
            message
          },
          result {
            id,
            at {
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
              at: "#{attrs.address}"
            }
          ) {
            successful,
            messages {
              field
              message
            },
            result {
              id,
              at {
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
