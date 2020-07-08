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

    assert count_categories(conn) ==
             %{"data" => %{"countCategories" => 1}}

    %{"data" => %{"categories" => [cat]}} = get_categories(conn)

    assert cat["id"]
    assert "test" == cat["name"]
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
end
