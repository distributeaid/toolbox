defmodule Ferry.ApiClient.User do
  @moduledoc """
  Helper module that provides with a convenience GraphQL client api
  for dealing with Users and Roles
  """

  import Ferry.ApiClient.GraphCase

  @doc """
  Run a GraphQL query that counts users
  """
  @spec count_users(Plug.Conn.t()) :: map
  def count_users(conn) do
    graphql(conn, """
    {
      countUsers
    }
    """)
  end

  @doc """
  Run a GraphQL query that retuns a collection
  of users
  """
  @spec get_users(Plug.Conn.t()) :: map
  def get_users(conn) do
    graphql(conn, """
    {
      users {
        id,
        email,
        groups {
          group {
            id
            name
          },
          role
        }
      }
    }
    """)
  end

  @doc """
  Run a GraphQL query that retuns a single
  user, given its id
  """
  @spec get_user(Plug.Conn.t(), String.t()) :: map
  def get_user(conn, id) do
    graphql(conn, """
     {
      user(id: "#{id}") {
        id,
        email,
        groups {
          group {
            id
            name
          },
          role
        }
      }
    }
    """)
  end

  @doc """
  Run a GraphQL mutation that sets a role
  for a given user in a group
  """
  @spec set_user_role(Plug.Conn.t(), map()) :: map()
  def set_user_role(conn, attrs) do
    graphql(conn, """
      mutation {
        setUserRole(user: "#{attrs.user}", group: "#{attrs.group}", role: "#{attrs.role}") {
          successful,
          messages { field, message },
          result {
            id,
            email,
            groups {
              group {
                id,
                name
              },
              role
            }
          }
        }
      }
    """)
  end

  @doc """
  Run a GraphQL mutation that deletes a role
  for a given user in a group
  """
  @spec set_user_role(Plug.Conn.t(), map()) :: map()
  def delete_user_role(conn, attrs) do
    graphql(conn, """
      mutation {
        deleteUserRole(user: "#{attrs.user}", group: "#{attrs.group}", role: "#{attrs.role}") {
          successful,
          messages { field, message },
          result {
            id,
            email,
            groups {
              group {
                id,
                name
              },
              role
            }
          }
        }
      }
    """)
  end
end
