defmodule Ferry.ItemApiTest do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.{Category, Item}

  test "count items where there are none", %{conn: conn} do
    assert count_items(conn) ==
             %{"data" => %{"countItems" => 0}}
  end

  test "create one item", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "createCategory" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => clothing
          }
        }
      }
    } = create_category(conn, %{name: "clothing"})

    %{
      "data" => %{
        "createItem" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => id,
            "name" => "t-shirts"
          }
        }
      }
    } =
      create_item(conn, %{
        category: clothing,
        name: "t-shirts"
      })

    assert id

    # Verify the item was created
    assert count_items(conn) ==
             %{"data" => %{"countItems" => 1}}

    # verify we can fetch that item given its id
    %{
      "data" => %{
        "item" => %{
          "id" => ^id,
          "name" => "t-shirts",
          "category" => %{
            "name" => "clothing",
            "id" => ^clothing
          }
        }
      }
    } = get_item(conn, id)

    # verify we can fetch that item, given its category
    # and its name

    %{
      "data" => %{
        "itemByName" => %{
          "id" => ^id,
          "name" => "t-shirts",
          "category" => %{
            "name" => "clothing",
            "id" => ^clothing
          }
        }
      }
    } = get_item_by_name(conn, clothing, "t-shirts")
  end

  test "create item with invalid data", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "createCategory" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => clothing
          }
        }
      }
    } = create_category(conn, %{name: "clothing"})

    %{
      "data" => %{
        "createItem" => %{
          "successful" => false,
          "messages" => [
            %{"field" => "name", "message" => "can't be blank"}
          ]
        }
      }
    } = create_item(conn, %{category: clothing, name: ""})
  end

  test "fetch a item that does not exist", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "createCategory" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => clothing
          }
        }
      }
    } = create_category(conn, %{name: "clothing"})

    %{
      "data" => %{
        "itemByName" => nil
      },
      "errors" => [error]
    } = get_item_by_name(conn, clothing, "t-shirts")

    assert "item not found" == error["message"]
  end

  test "update a item that does not exist", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "updateItem" => %{
          "successful" => false,
          "messages" => [
            error
          ]
        }
      }
    } =
      update_item(conn, %{
        id: 123,
        name: "trousers"
      })

    assert "item not found" == error["message"]
  end

  test "update existing item", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "createCategory" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => clothing
          }
        }
      }
    } = create_category(conn, %{name: "clothing"})

    %{
      "data" => %{
        "createItem" => %{
          "successful" => true,
          "result" => %{
            "id" => id
          }
        }
      }
    } = create_item(conn, %{category: clothing, name: "t-shirts"})

    %{
      "data" => %{
        "updateItem" => %{
          "successful" => true,
          "result" => %{
            "id" => ^id,
            "name" => "trousers"
          }
        }
      }
    } =
      update_item(conn, %{
        id: id,
        name: "trousers"
      })
  end

  test "update item with invalid data", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "createCategory" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => clothing
          }
        }
      }
    } = create_category(conn, %{name: "clothing"})

    %{
      "data" => %{
        "createItem" => %{
          "successful" => true
        }
      }
    } = create_item(conn, %{category: clothing, name: "t-shirts"})

    %{
      "data" => %{
        "createItem" => %{
          "successful" => true,
          "result" => %{
            "id" => trousers
          }
        }
      }
    } = create_item(conn, %{category: clothing, name: "trousers"})

    %{
      "data" => %{
        "updateItem" => %{
          "successful" => false
        }
      }
    } =
      update_item(conn, %{
        id: trousers,
        name: "t-shirts"
      })
  end

  test "delete a item that does not exist", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "deleteItem" => %{
          "successful" => false,
          "messages" => [
            error
          ]
        }
      }
    } = delete_item(conn, 123)

    assert "item not found" == error["message"]
  end

  test "delete a item", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "createCategory" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => clothing
          }
        }
      }
    } = create_category(conn, %{name: "clothing"})

    %{
      "data" => %{
        "createItem" => %{
          "successful" => true,
          "result" => %{
            "id" => id
          }
        }
      }
    } = create_item(conn, %{category: clothing, name: "t-shirts"})

    assert count_items(conn) ==
             %{"data" => %{"countItems" => 1}}

    %{
      "data" => %{
        "deleteItem" => %{
          "successful" => true
        }
      }
    } = delete_item(conn, id)

    assert count_items(conn) ==
             %{"data" => %{"countItems" => 0}}
  end
end
