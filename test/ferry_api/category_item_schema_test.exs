defmodule Ferry.CategoryItemSchemaTest do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.{Category, Item}

  test "fetch a category and its items", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "createCategory" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => clothing,
            "name" => "clothing"
          }
        }
      }
    } = create_category(conn, %{name: "clothing"})

    # create an item for that category
    %{
      "data" => %{
        "createItem" => %{
          "successful" => true,
          "result" => %{
            "id" => id
          }
        }
      }
    } =
      create_item(conn, %{
        category: clothing,
        name: "t-shirts"
      })

    # verify we can get that category and its items
    %{
      "data" => %{
        "category" => %{
          "items" => [
            %{"id" => ^id}
          ]
        }
      }
    } = get_category_with_items(conn, clothing)

    # create a second category, with no items

    %{
      "data" => %{
        "createCategory" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => food,
            "name" => "food"
          }
        }
      }
    } = create_category(conn, %{name: "food"})

    # verify that category has no items
    %{
      "data" => %{
        "category" => %{
          "items" => []
        }
      }
    } = get_category_with_items(conn, food)

    # verify we can get both categories and their associated
    # items

    %{
      "data" => %{
        "categories" => [
          %{
            "name" => "clothing",
            "items" => [
              %{"name" => "t-shirts"}
            ]
          },
          %{
            "name" => "food",
            "items" => []
          }
        ]
      }
    } = get_categories_with_items(conn)
  end
end
