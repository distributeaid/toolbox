defmodule Ferry.ApiClient.Mod do
  @moduledoc """
  Helper module that provides with a convenience GraphQL client api
  for dealing with Mods in tests.
  """

  import Ferry.ApiClient.Graphql

  @doc """
  Run a GraphQL query that counts mods
  """
  @spec count_mods(Plug.Conn.t()) :: map()
  def count_mods(conn) do
    graphql(conn, "{ countMods }")
  end

  # @doc """
  # Run a GraphQL query that retuns a collection
  # of categories
  # """
  # @spec get_categories(Plug.Conn.t()) :: map()
  # def get_categories(conn) do
  #   graphql(conn, """
  #   {
  #     categories {
  #       id,
  #       name
  #     }
  #   }
  #   """)
  # end

  @doc """
  Run a GraphQL query that retuns a collection
  of mods
  """
  @spec get_mods(Plug.Conn.t()) :: map()
  def get_mods(conn) do
    graphql(conn, """
    {
      mods {
        id,
        name
      }
    }
    """)
  end

  @doc """
  Run a GraphQL query that retuns a collection
  of mods and their values

  """
  @spec get_mods_with_values(Plug.Conn.t()) :: map()
  def get_mods_with_values(conn) do
    graphql(conn, """
    {
      mods {
        id,
        name,
        values {
          id,
          value
        }
      }
    }
    """)
  end

  @doc """
  Run a GraphQL query that retuns a single
  mod, given its name.
  """
  @spec get_mod(Plug.Conn.t(), String.t()) :: map()
  def get_mod(conn, id) do
    graphql(conn, """
    {
      mod(id: "#{id}") {
        id,
        name
      }
    }
    """)
  end

  @doc """
  Run a GraphQL query that retuns a single
  mod, given its name.
  """
  @spec get_mod_by_name(Plug.Conn.t(), String.t()) :: map()
  def get_mod_by_name(conn, name) do
    graphql(conn, """
    {
      modByName(name: "#{name}") {
        id,
        name
      }
    }
    """)
  end

  @doc """
  Run a GraphQL mutation that creates a mod
  """
  @spec create_mod(Plug.Conn.t(), map()) :: map()
  def create_mod(conn, attrs) do
    graphql(conn, """
      mutation {
        createMod (
          modInput: {
            name: "#{attrs.name}",
            description: "#{attrs.description}",
            type: "#{attrs.type}"
          }
        ) {
          successful,
          messages {
            field,
            message
          },
          result {
            id,
            name
          }
        }
      }
    """)
  end

  @doc """
  Run a GraphQL mutation that updates an existing mod,
  """
  @spec update_mod(Plug.Conn.t(), map()) :: map()
  def update_mod(conn, attrs) do
    graphql(conn, """
      mutation {
        updateMod (
          modInput: {
            name: "#{attrs.name}"
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
            name
          }
        }
      }
    """)
  end

  @doc """
  Run a GraphQL mutation that deletes a mod, given its id
  """
  @spec delete_mod(Plug.Conn.t(), String.t()) :: map()
  def delete_mod(conn, id) do
    graphql(conn, """
    mutation {
      deleteMod(id: "#{id}") {
        successful,
        messages {
          field,
          message
        },
        result {
          id,
          name
        }
      }
    }
    """)
  end
end
