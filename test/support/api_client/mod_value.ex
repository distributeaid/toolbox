defmodule Ferry.ApiClient.ModValue do
  @moduledoc """
  Helper module that provides with a convenience GraphQL client api
  for dealing with Mod Values in tests.
  """

  import Ferry.ApiClient.Graphql

  @doc """
  Run a GraphQL query that counts mod values
  """
  @spec count_mod_values(Plug.Conn.t()) :: map()
  def count_mod_values(conn) do
    graphql(conn, "{ countModValues }")
  end

  @doc """
  Run a GraphQL query that retuns a collection
  of all mod values
  """
  @spec get_mod_values(Plug.Conn.t()) :: map()
  def get_mod_values(conn) do
    graphql(conn, """
    {
      modValues {
        id,
        mod { id, name },
        value
      }
    }
    """)
  end

  @doc """
  Run a GraphQL query that retuns a single
  mod value, given its name.
  """
  @spec get_mod_value(Plug.Conn.t(), String.t()) :: map()
  def get_mod_value(conn, id) do
    graphql(conn, """
    {
      modValue(id: "#{id}") {
        id,
        mod { id, name },
        value
      }
    }
    """)
  end

  @doc """
  Run a GraphQL mutation that creates a mod value
  """
  @spec create_mod_value(Plug.Conn.t(), map()) :: map()
  def create_mod_value(conn, attrs) do
    graphql(conn, """
      mutation {
        createModValue (
          modValueInput: {
            mod: "#{attrs.mod}",
            value: "#{attrs.value}"
          }
        ) {
          successful,
          messages {
            field,
            message
          },
          result {
            id,
            mod { id, name },
            value
          }
        }
      }
    """)
  end

  @doc """
  Run a GraphQL mutation that updates an existing mod value,
  """
  @spec update_mod_value(Plug.Conn.t(), map()) :: map()
  def update_mod_value(conn, attrs) do
    graphql(conn, """
      mutation {
        updateModValue (
          modValueInput: {
            mod: "#{attrs.mod}",
            value: "#{attrs.value}"
          },
          id: "#{attrs.id}"
        ) {
          successful,
          messages {
            field,
            message
          },
          result {
            id,
            mod { id, name },
            value
          }
        }
      }
    """)
  end

  @doc """
  Run a GraphQL mutation that deletes a mod value, given its id
  """
  @spec delete_mod_value(Plug.Conn.t(), String.t()) :: map()
  def delete_mod_value(conn, id) do
    graphql(conn, """
    mutation {
      deleteModValue(id: "#{id}") {
        successful,
        messages {
          field,
          message
        },
        result {
          id,
          mod { id, name },
          value
        }
      }
    }
    """)
  end
end
