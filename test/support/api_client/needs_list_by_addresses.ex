defmodule Ferry.ApiClient.NeedsListByAddresses do
  @moduledoc """
  Helper module that provides with a convenience GraphQL client api
  for dealing with Needs Lists by Addresses in tests
  """

  import Ferry.ApiClient.GraphCase

  @doc """
  Run a GraphQL query that returns an aggregated needs list
  for a list of address ids. The needs list is returned for the current date
  """
  @spec get_current_needs_list_by_addresses(Plug.Conn.t(), [String.t()]) :: map()
  def get_current_needs_list_by_addresses(conn, ids) do
    ids = Enum.join(ids, ",")

    graphql(conn, """
    {
      currentNeedsListByAddresses(addresses: [#{ids}]) {
        entries {
          amount,
          item {
            name,
            category {
              name
            },
          },
          modValues {
            modValue{
              value,
              mod {
                name
              }
            }
          }
        }
      }
    }
    """)
  end
end
