defmodule Ferry.ApiClient.Item do
  @moduledoc """
  Helper module that provides with a convenience GraphQL client api
  for dealing with items in tests.
  """

  import Ferry.ApiClient.GraphCase

  @doc """
  Run a GraphQL query that counts items
  """
  @spec count_items(Plug.Conn.t()) :: map()
  def count_items(conn) do
    graphql(conn, "{ countItems }")
  end

  @doc """
  Run a GraphQL query that retuns a single
  item, given its id.
  """
  @spec get_item(Plug.Conn.t(), String.t()) :: map()
  def get_item(conn, id) do
    graphql(conn, """
    {
      item(id: "#{id}") {
        id,
        name,
        category {
          id,
          name
        }
      }
    }
    """)
  end

  @doc """
  Run a GraphQL query that retuns a single
  item, given its id. It also returns mods associated to that item.
  """
  @spec get_item_with_mods(Plug.Conn.t(), String.t()) :: map()
  def get_item_with_mods(conn, id) do
    graphql(conn, """
    {
      item(id: "#{id}") {
        id,
        name,
        mods {
          id,
          name
        }
      }
    }
    """)
  end

  @doc """
  Run a GraphQL query that retuns a single
  item, given its name. Since the name of an item is not unique across
  all categories, we also need to specify the category.

  """
  @spec get_item_by_name(Plug.Conn.t(), String.t(), String.t()) :: map()
  def get_item_by_name(conn, category, name) do
    graphql(conn, """
    {
      itemByName(category: "#{category}", name: "#{name}") {
        id,
        name,
        category {
          id,
          name
        }
      }
    }
    """)
  end

  @doc """
  Run a GraphQL mutation that creates a item
  """
  @spec create_item(Plug.Conn.t(), map()) :: map()
  def create_item(conn, attrs) do
    graphql(conn, """
      mutation {
        createItem (
          itemInput: {
            name: "#{attrs.name}",
            category: "#{attrs.category}"
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
  Run a GraphQL mutation that updates an existing item,
  """
  @spec update_item(Plug.Conn.t(), map()) :: map()
  def update_item(conn, attrs) do
    graphql(conn, """
      mutation {
        updateItem (
          itemInput: {
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
  Run a GraphQL mutation that moves the given item to the given category
  """
  @spec update_item_category(Plug.Conn.t(), String.t(), String.t()) :: map()
  def update_item_category(conn, id, category) do
    graphql(conn, """
    mutation {
      updateItemCategory(id: "#{id}", category: "#{category}") {
        successful,
        messages {
          field,
          message
        },
        result {
          id,
          name,
          category {
            id,
            name
          }
        }
      }
    }
    """)
  end

  @doc """
  Run a GraphQL mutation that deletes a item, given its id
  """
  @spec delete_item(Plug.Conn.t(), String.t()) :: map()
  def delete_item(conn, id) do
    graphql(conn, """
    mutation {
      deleteItem(id: "#{id}") {
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
