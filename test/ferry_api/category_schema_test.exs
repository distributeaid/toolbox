defmodule Ferry.CategoryTest do
  use FerryWeb.ConnCase, async: true

  test "count categories where there are none", %{conn: conn} do
    assert count_categories(conn) ==
             %{"data" => %{"countCategories" => 0}}
  end

  test "get all categories where there are none", %{conn: conn} do
    assert get_categories(conn) == %{"data" => %{"categories" => []}}
  end

  test "create one category", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "createCategory" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => id,
            "name" => "test"
          }
        }
      }
    } = create_category(conn, "test")

    assert id

    # verify that category is returned in the collection
    # of all categories
    assert count_categories(conn) ==
             %{"data" => %{"countCategories" => 1}}

    %{"data" => %{"categories" => [cat]}} = get_categories(conn)

    assert cat["id"]
    assert "test" == cat["name"]

    # verify we can fetch that category given its id
    %{
      "data" => %{
        "category" => ^cat
      }
    } = get_category(conn, cat["id"])
  end

  test "create category with invalid data", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "createCategory" => %{
          "successful" => false,
          "messages" => [
            %{"field" => "name", "message" => "can't be blank"}
          ]
        }
      }
    } = create_category(conn, "")
  end

  test "fetch a category that does not exist", %{conn: conn} do
    %{
      "data" => %{
        "categoryByName" => nil
      },
      "errors" => [error]
    } = get_category_by_name(conn, "test")

    assert "category not found" == error["message"]
  end

  test "update a category that does not exist", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "updateCategory" => %{
          "successful" => false,
          "messages" => [
            error
          ]
        }
      }
    } =
      update_category(conn, %{
        id: 123,
        name: "some name"
      })

    assert "category not found" == error["message"]
  end

  test "update existing category", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "createCategory" => %{
          "successful" => true,
          "result" => %{
            "id" => id
          }
        }
      }
    } = create_category(conn, "test")

    %{
      "data" => %{
        "updateCategory" => %{
          "successful" => true,
          "result" => %{
            "id" => ^id,
            "name" => "new name"
          }
        }
      }
    } =
      update_category(conn, %{
        id: id,
        name: "new name"
      })
  end

  test "update category with invalid data", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "createCategory" => %{
          "successful" => true
        }
      }
    } = create_category(conn, "test")

    %{
      "data" => %{
        "createCategory" => %{
          "successful" => true,
          "result" => %{
            "id" => id2
          }
        }
      }
    } = create_category(conn, "testi2")

    %{
      "data" => %{
        "updateCategory" => %{
          "successful" => false
        }
      }
    } =
      update_category(conn, %{
        id: id2,
        name: "test"
      })
  end

  test "delete a category that does not exist", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "deleteCategory" => %{
          "successful" => false,
          "messages" => [
            error
          ]
        }
      }
    } = delete_category(conn, 123)

    assert "category not found" == error["message"]
  end

  test "delete a category", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "createCategory" => %{
          "successful" => true,
          "result" => %{
            "id" => id
          }
        }
      }
    } = create_category(conn, "test")

    assert count_categories(conn) ==
             %{"data" => %{"countCategories" => 1}}

    %{
      "data" => %{
        "deleteCategory" => %{
          "successful" => true
        }
      }
    } = delete_category(conn, id)

    assert count_categories(conn) ==
             %{"data" => %{"countCategories" => 0}}
  end

  defp count_categories(conn) do
    graphql_query(conn, "{ countCategories }")
  end

  defp get_categories(conn) do
    graphql_query(conn, """
    {
      categories {
        id,
        name
      }
    }
    """)
  end

  defp get_category(conn, id) do
    graphql_query(conn, """
    {
      category(id: "#{id}") {
        id,
        name
      }
    }
    """)
  end

  defp get_category_by_name(conn, name) do
    graphql_query(conn, """
    {
      categoryByName(name: "#{name}") {
        id,
        name
      }
    }
    """)
  end

  defp create_category(conn, name) do
    graphql_query(conn, """
      mutation {
        createCategory (
          categoryInput: {
            name: "#{name}"
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

  defp update_category(conn, attrs) do
    graphql_query(conn, """
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

  defp delete_category(conn, id) do
    graphql_query(conn, """
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
end
