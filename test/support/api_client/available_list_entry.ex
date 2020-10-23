defmodule Ferry.ApiClient.AvailableListEntry do
  @moduledoc """
  Helper module that provides with a convenience GraphQL client api
  for dealing with Entries in tests.
  """

  import Ferry.ApiClient.GraphCase

  @doc """
  Run a GraphQL query that retuns an entry given its
  id
  """
  @spec get_available_list_entry(Plug.Conn.t(), String.t()) :: map()
  def get_available_list_entry(conn, id) do
    graphql(conn, """
    {
      availableListEntry(id: "#{id}") {
        id,
        list {
          id
        },
        amount,
        item {
          id,
          name
          category {
            id,
            name
          }
        }
      }
    }
    """)
  end

  @doc """
  Run a GraphQL mutation that creates a entry
  under a given aid list
  """
  @spec create_available_list_entry(Plug.Conn.t(), map()) :: map()
  def create_available_list_entry(conn, attrs) do
    graphql(conn, """
      mutation {
        createAvailableListEntry (
          entryInput: {
            list: "#{attrs.list}",
            amount: #{attrs[:amount] || 1},
            item: "#{attrs.item}"
          }
        ) {
          successful,
          messages { field, message },
          result {
            id,
            list {
              id
            },
            amount,
            item {
              id,
              name
              category {
                id,
                name
              }
            }
          }
        }
      }
    """)
  end

  @doc """
  Run a GraphQL mutation that updates a list entry.

  We are using an entryInput type for consistency, however,
  in reality only the amount can be changed at the moment.
  """
  @spec update_available_list_entry(Plug.Conn.t(), map()) :: map()
  def update_available_list_entry(conn, attrs) do
    graphql(conn, """
      mutation {
        updateAvailableListEntry(
          id: "#{attrs.id}",
          entryInput: {
            list: "#{attrs.list}",
            amount: #{attrs[:amount] || 1},
            item: "#{attrs.item}"
          }
        ){
          successful,
          messages { field, message },
          result {
            id,
            list {
              id,
            },
            amount,
            item {
              id,
              name
              category {
                id,
                name
              }
            }
          }
        }
      }
    """)
  end

  @doc """
  Run a GraphQL mutation that deletes a available list entry, given its id
  """
  @spec delete_available_list_entry(Plug.Conn.t(), String.t()) :: map()
  def delete_available_list_entry(conn, id) do
    graphql(conn, """
      mutation {
        deleteAvailableListEntry(id: "#{id}") {
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
