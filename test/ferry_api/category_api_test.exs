defmodule Ferry.CategoryApiTest do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.Category

  setup context do
    Ferry.Fixture.DistributeAid.setup(context, auth: true)
  end

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
    } = create_category(conn, %{name: "test"})

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
    } = create_category(conn, %{name: ""})
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
    } = create_category(conn, %{name: "test"})

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
    } = create_category(conn, %{name: "test"})

    %{
      "data" => %{
        "createCategory" => %{
          "successful" => true,
          "result" => %{
            "id" => id2
          }
        }
      }
    } = create_category(conn, %{name: "test2"})

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
    } = create_category(conn, %{name: "test"})

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
end
