defmodule Ferry.ApiClient.NeedsListByGroups do
  @moduledoc """
  Helper module that provides with a convenience GraphQL client api
  for dealing with Needs Lists by Groups in tests
  """

  import Ferry.ApiClient.GraphCase

  @doc """
  Run a GraphQL query that returns an aggregated needs list
  for a list of group ids. The needs list is returned for the current date
  """
  @spec get_current_needs_list_by_groups(Plug.Conn.t(), map()) :: map()
  def get_current_needs_list_by_groups(conn, attrs) do
    ids = Enum.join(attrs.groups, ",")

    graphql(conn, """
    {
      currentNeedsListByGroups(groups: [#{ids}]) {
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
  for a list of group ids and a date range
  """
  @spec get_needs_list_by_groups(Plug.Conn.t(), map()) :: map()
  def get_needs_list_by_groups(conn, attrs) do
    ids = Enum.join(attrs.groups, ",")

    from = DateTime.to_iso8601(attrs.from)
    to = DateTime.to_iso8601(attrs.to)

    graphql(conn, """
    {
      needsListByGroups(groups: [#{ids}], from: "#{from}", to: "#{to}") {
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
