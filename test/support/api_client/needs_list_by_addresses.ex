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
  @spec get_current_needs_list_by_addresses(Plug.Conn.t(), map()) :: map()
  def get_current_needs_list_by_addresses(conn, attrs) do
    ids = Enum.join(attrs.addresses, ",")

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

  @doc """
  Run a GraphQL query that returns an aggregated needs list
  for a list of address ids and a date range
  """
  @spec get_needs_list_by_addresses(Plug.Conn.t(), map()) :: map()
  def get_needs_list_by_addresses(conn, attrs) do
    ids = Enum.join(attrs.addresses, ",")

    from = DateTime.to_iso8601(attrs.from)
    to = DateTime.to_iso8601(attrs.to)

    graphql(conn, """
    {
      needsListByAddresses(addresses: [#{ids}], from: "#{from}", to: "#{to}") {
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
