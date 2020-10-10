defmodule Ferry.ApiClient.NeedsList do
  @moduledoc """
  Helper module that provides with a convenience GraphQL client api
  for dealing with Needs Lists in tests.
  """

  import Ferry.ApiClient.GraphCase

  @doc """
  Run a GraphQL query that returns all needs for a
  project that fall within the given date range
  """
  @spec get_project_needs_lists(Plug.Conn.t(), map()) :: map()
  def get_project_needs_lists(conn, attrs) do
    from = DateTime.to_iso8601(attrs.from)
    to = DateTime.to_iso8601(attrs.to)

    graphql(conn, """
    {
      needsLists(project: "#{attrs.id}", from: "#{from}", to: "#{to}") {
        id,
        from,
        to
      }
    }
    """)
  end

  @doc """
  Run a GraphQL query that retuns the current needs list for
  a project
  """
  @spec get_project_current_needs_list(Plug.Conn.t(), map()) :: map()
  def get_project_current_needs_list(conn, attrs) do
    graphql(conn, """
    {
      currentNeedsList(project: "#{attrs.id}") {
        id,
        from,
        to
      }
    }
    """)
  end

  @doc """
  Run a GraphQL query that retuns a single needs list, given its id
  """
  @spec get_project_current_needs_list(Plug.Conn.t(), String.t()) :: map()
  def get_needs_list(conn, id) do
    graphql(conn, """
    {
      needsList(id: "#{id}") {
        id,
        project {
          id
        },
        from,
        to
      }
    }
    """)
  end

  @doc """
  Run a GraphQL mutation that creates a needs list
  """
  @spec create_needs_list(Plug.Conn.t(), map()) :: map()
  def create_needs_list(conn, attrs) do
    from = DateTime.to_iso8601(attrs.from)
    to = DateTime.to_iso8601(attrs.to)

    graphql(conn, """
      mutation {
        createNeedsList(
          needsListInput: {
            project: "#{attrs.project}",
            from: "#{from}",
            to: "#{to}"
          }
        ) {
          successful,
          messages {
            field
            message
          },
          result {
            id,
            project {
              id
            }
            from,
            to
          }
        }
      }
    """)
  end

  @doc """
  Run a GraphQL mutation that creates a needs list
  """
  @spec update_needs_list(Plug.Conn.t(), map()) :: map()
  def update_needs_list(conn, attrs) do
    from = DateTime.to_iso8601(attrs.from)
    to = DateTime.to_iso8601(attrs.to)

    graphql(conn, """
      mutation {
        updateNeedsList(
            id: "#{attrs.id}",
            needsListInput: {
              project: "#{attrs.project}",
              from: "#{from}",
              to: "#{to}"
            }
          ) {
            successful,
            messages {
              field
              message
            },
            result {
              id,
              project {
                id
              }
              from,
              to
            }
          }
        }
    """)
  end

  @doc """
  Run a GraphQL mutation that deletes a needs list, given its id
  """
  @spec delete_needs_list(Plug.Conn.t(), String.t()) :: map()
  def delete_needs_list(conn, id) do
    graphql(conn, """
      mutation {
        deleteNeedsList(id: "#{id}") {
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
