defmodule Ferry.ApiClient.Category do
  @moduledoc """
  Helper module that provides with a convenience GraphQL client api
  for dealing with Categories in tests.
  """

  import Ferry.ApiClient.Graphql

  @doc """
  Run a GraphQL query that counts categories
  """
  @spec count_categories(Plug.Conn.t()) :: map()
  def count_categories(conn) do
    graphql(conn, "{ countCategories }")
  end

  @doc """
  Run a GraphQL query that retuns a collection
  of categories
  """
  @spec get_categories(Plug.Conn.t()) :: map()
  def get_categories(conn) do
    graphql(conn, """
    {
      categories {
        id,
        name
      }
    }
    """)
  end

  @doc """
  Run a GraphQL query that retuns a single
  category, given its id.
  """
  @spec get_category(Plug.Conn.t(), String.t()) :: map()
  def get_category(conn, id) do
    graphql(conn, """
    {
      category(id: "#{id}") {
        id,
        name
      }
    }
    """)
  end

  @doc """
  Run a GraphQL query that retuns a single
  category, given its name.
  """
  @spec get_category_by_name(Plug.Conn.t(), String.t()) :: map()
  def get_category_by_name(conn, name) do
    graphql(conn, """
    {
      categoryByName(name: "#{name}") {
        id,
        name
      }
    }
    """)
  end

  @doc """
  Run a GraphQL mutation that creates a category
  """
  @spec create_category(Plug.Conn.t(), map()) :: map()
  def create_category(conn, attrs) do
    graphql(conn, """
      mutation {
        createCategory (
          categoryInput: {
            name: "#{attrs.name}"
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
  Run a GraphQL mutation that updates an existing category,
  """
  @spec update_category(Plug.Conn.t(), map()) :: map()
  def update_category(conn, attrs) do
    graphql(conn, """
      mutation {
        updateCategory (
          categoryInput: {
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
  Run a GraphQL mutation that deletes a category, given its id
  """
  @spec delete_category(Plug.Conn.t(), String.t()) :: map()
  def delete_category(conn, id) do
    graphql(conn, """
    mutation {
      deleteCategory(id: "#{id}") {
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
  Run a GraphQL query that retuns a single
  category, given its id. It also returns its associated items.
  """
  @spec get_category(Plug.Conn.t(), String.t()) :: map()
  def get_category_with_items(conn, id) do
    graphql(conn, """
    {
      category(id: "#{id}") {
        id,
        name,
        items {
          id,
          name
        }
      }
    }
    """)
  end

  @doc """
  Run a GraphQL query that returns all categories and their items
  """
  @spec get_categories_with_items(Plug.Conn.t()) :: map()
  def get_categories_with_items(conn) do
    graphql(conn, """
     {
      categories {
        id,
        name,
        items {
          id,
          name
        }
      }
    }
    """)
  end
end
