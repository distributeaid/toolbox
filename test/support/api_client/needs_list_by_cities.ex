defmodule Ferry.ApiClient.NeedsListByCities do
  @moduledoc """
  Helper module that provides with a convenience GraphQL client api
  for dealing with Needs Lists by postal cities in tests
  """

  import Ferry.ApiClient.GraphCase

  @doc """
  Run a GraphQL query that returns an aggregated needs list
  for a list of postal cities. The needs list is returned for the current date
  """
  @spec get_current_needs_list_by_cities(Plug.Conn.t(), map()) :: map()
  def get_current_needs_list_by_cities(conn, attrs) do
    cities = attrs.cities |> Enum.map(fn city -> "\"#{city}\"" end) |> Enum.join(",")

    graphql(conn, """
    {
      currentNeedsListByCities(cities: [#{cities}]) {
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
  for a list of postal cities and a date range
  """
  @spec get_needs_list_by_cities(Plug.Conn.t(), map()) :: map()
  def get_needs_list_by_cities(conn, attrs) do
    cities = attrs.cities |> Enum.map(fn city -> "\"#{city}\"" end) |> Enum.join(",")

    from = DateTime.to_iso8601(attrs.from)
    to = DateTime.to_iso8601(attrs.to)

    graphql(conn, """
    {
      needsListByCities(cities: [#{cities}], from: "#{from}", to: "#{to}") {
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
