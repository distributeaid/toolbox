defmodule Ferry.ItemSchemaTest do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.{Category, Item}

  test "count items where there are none", %{conn: conn} do
    assert count_items(conn) ==
             %{"data" => %{"countItems" => 0}}
  end

  test "get all items where there are none", %{conn: conn} do
    assert get_items(conn) == %{"data" => %{"items" => []}}
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
            "id" => category
          }
        }
      }
    } = create_category(conn, %{name: "test"})

    %{
      "data" => %{
        "createItem" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => id,
            "name" => "mask"
          }
        }
      }
    } =
      create_item(conn, %{
        category: category,
        name: "mask"
      })

    assert id

    # verify that item is returned in the collection
    # of all items
    assert count_items(conn) ==
             %{"data" => %{"countItems" => 1}}

    %{"data" => %{"items" => [item]}} = get_items(conn)

    item_id = item["id"]
    assert item_id
    assert "mask" == item["name"]

    # verify we can fetch that item given its id
    %{
      "data" => %{
        "item" => ^item
      }
    } = get_item(conn, item["id"])
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
            "id" => category
          }
        }
      }
    } = create_category(conn, %{name: "test"})

    %{
      "data" => %{
        "createItem" => %{
          "successful" => false,
          "messages" => [
            %{"field" => "name", "message" => "can't be blank"}
          ]
        }
      }
    } = create_item(conn, %{category: category, name: ""})
  end

  test "fetch a item that does not exist", %{conn: conn} do
    %{
      "data" => %{
        "itemByName" => nil
      },
      "errors" => [error]
    } = get_item_by_name(conn, "test")

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
        name: "some name"
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
            "id" => category
          }
        }
      }
    } = create_category(conn, %{name: "test"})

    %{
      "data" => %{
        "createItem" => %{
          "successful" => true,
          "result" => %{
            "id" => id
          }
        }
      }
    } = create_item(conn, %{category: category, name: "mask"})

    %{
      "data" => %{
        "updateItem" => %{
          "successful" => true,
          "result" => %{
            "id" => ^id,
            "name" => "new name"
          }
        }
      }
    } =
      update_item(conn, %{
        id: id,
        name: "Mask"
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
            "id" => category
          }
        }
      }
    } = create_category(conn, %{name: "test"})

    %{
      "data" => %{
        "createItem" => %{
          "successful" => true
        }
      }
    } = create_item(conn, %{category: category, name: "mask"})

    %{
      "data" => %{
        "createItem" => %{
          "successful" => true,
          "result" => %{
            "id" => id2
          }
        }
      }
    } = create_item(conn, %{category: category, name: "other"})

    %{
      "data" => %{
        "updateItem" => %{
          "successful" => false
        }
      }
    } =
      update_item(conn, %{
        id: id2,
        name: "mask"
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
            "id" => category
          }
        }
      }
    } = create_category(conn, %{name: "test"})

    %{
      "data" => %{
        "createItem" => %{
          "successful" => true,
          "result" => %{
            "id" => id
          }
        }
      }
    } = create_item(conn, %{category: category, name: "mask"})

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
