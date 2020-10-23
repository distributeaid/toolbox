defmodule Ferry.ApiClient.AvailableListEntryModValue do
  @moduledoc """
  Helper module that provides with a convenience GraphQL client api
  for dealing with Entries in tests.
  """

  import Ferry.ApiClient.GraphCase

  @doc """
  Adds a mod value to an existing available list entry

  """
  @spec add_mod_value_to_available_list_entry(Plug.Conn.t(), map()) :: map()
  def add_mod_value_to_available_list_entry(conn, attrs) do
    graphql(conn, """
      mutation {
        addModValueToAvailableListEntry (
          entryModValueInput: {
            entry: "#{attrs.entry}",
            modValue: "#{attrs.mod_value}"
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
            modValues {
              modValue {
                id,
                value,
                mod {
                  id,
                  name
                }
              },
            },
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
  Removes a mod value from an existing available list entry

  """
  @spec remove_mod_value_from_available_list_entry(Plug.Conn.t(), map()) :: map()
  def remove_mod_value_from_available_list_entry(conn, attrs) do
    graphql(conn, """
      mutation {
        removeModValueFromAvailableListEntry (
          entryModValueInput: {
            entry: "#{attrs.entry}",
            modValue: "#{attrs.mod_value}"
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
            modValues {
              modValue {
                id,
                value,
                mod {
                  id,
                  name
                }
              },
            },
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
end
