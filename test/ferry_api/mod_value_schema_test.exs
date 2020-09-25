defmodule Ferry.ModValueSchemaTest do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.{Mod, ModValue}

  test "count mod values where there are none", %{conn: conn} do
    assert count_mod_values(conn) ==
             %{"data" => %{"countModValues" => 0}}
  end

  test "get all mod values where there are none", %{conn: conn} do
    assert get_mod_values(conn) == %{"data" => %{"modValues" => []}}
  end

  test "create one mod value", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "createMod" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => mod,
            "name" => "tshirt-size"
          }
        }
      }
    } = create_mod(conn, %{name: "tshirt-size", description: "T-Shirt sizes", type: "select"})

    %{
      "data" => %{
        "createModValue" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => id,
            "value" => "small"
          }
        }
      }
    } = create_mod_value(conn, %{value: "small", mod: mod})

    assert count_mod_values(conn) ==
             %{"data" => %{"countModValues" => 1}}

    %{"data" => %{"modValues" => [mod_value]}} = get_mod_values(conn)

    assert id == mod_value["id"]
    assert "small" == mod_value["value"]

    # verify we can fetch that mod given its id
    %{
      "data" => %{
        "modValue" => ^mod_value
      }
    } = get_mod_value(conn, id)
  end

  test "create mod value with invalid data", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "createMod" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => mod,
            "name" => "tshirt-size"
          }
        }
      }
    } = create_mod(conn, %{name: "tshirt-size", description: "T-Shirt sizes", type: "select"})

    %{
      "data" => %{
        "createModValue" => %{
          "successful" => false,
          "messages" => [
            %{"field" => "value", "message" => "can't be blank"}
          ]
        }
      }
    } = create_mod_value(conn, %{value: "", mod: mod})

    assert count_mod_values(conn) ==
             %{"data" => %{"countModValues" => 0}}
  end

  test "fetch a mod value that does not exist", %{conn: conn} do
    %{
      "data" => %{
        "modValue" => nil
      },
      "errors" => [error]
    } = get_mod_value(conn, "1")

    assert "mod value not found" == error["message"]
  end

  test "update a mod value that does not exist", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "createMod" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => mod,
            "name" => "tshirt-size"
          }
        }
      }
    } = create_mod(conn, %{name: "tshirt-size", description: "T-Shirt sizes", type: "select"})

    %{
      "data" => %{
        "updateModValue" => %{
          "successful" => false,
          "messages" => [
            error
          ]
        }
      }
    } =
      update_mod_value(conn, %{
        id: "123",
        mod: mod,
        value: "test"
      })

    assert "mod value not found" == error["message"]
  end

  test "update existing mod value", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "createMod" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => mod,
            "name" => "tshirt-size"
          }
        }
      }
    } = create_mod(conn, %{name: "tshirt-size", description: "T-Shirt sizes", type: "select"})

    %{
      "data" => %{
        "createModValue" => %{
          "successful" => true,
          "result" => %{
            "id" => id
          }
        }
      }
    } = create_mod_value(conn, %{value: "small", mod: mod})

    %{
      "data" => %{
        "updateModValue" => %{
          "successful" => true,
          "result" => %{
            "id" => ^id,
            "value" => "medium"
          }
        }
      }
    } =
      update_mod_value(conn, %{
        id: id,
        mod: mod,
        value: "medium"
      })

    %{
      "data" => %{
        "modValue" => modValue
      }
    } = get_mod_value(conn, id)

    assert "medium" == modValue["value"]
    assert id == modValue["id"]
  end

  test "update mod value with invalid data", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "createMod" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => mod,
            "name" => "tshirt-size"
          }
        }
      }
    } = create_mod(conn, %{name: "tshirt-size", description: "T-Shirt sizes", type: "select"})

    %{
      "data" => %{
        "createModValue" => %{
          "successful" => true,
          "result" => %{
            "id" => id
          }
        }
      }
    } = create_mod_value(conn, %{value: "small", mod: mod})

    %{
      "data" => %{
        "updateModValue" => %{
          "successful" => false,
          "messages" => [
            error
          ]
        }
      }
    } =
      update_mod_value(conn, %{
        id: id,
        mod: mod,
        value: ""
      })

    assert "value" == error["field"]
    assert "can't be blank" == error["message"]
  end

  test "mod value is unique within a mod", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "createMod" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => mod,
            "name" => "tshirt-size"
          }
        }
      }
    } = create_mod(conn, %{name: "tshirt-size", description: "T-Shirt sizes", type: "select"})

    %{
      "data" => %{
        "createModValue" => %{
          "successful" => true,
          "result" => %{
            "id" => _
          }
        }
      }
    } = create_mod_value(conn, %{value: "small", mod: mod})

    %{
      "data" => %{
        "createModValue" => %{
          "successful" => true,
          "result" => %{
            "id" => medium
          }
        }
      }
    } = create_mod_value(conn, %{value: "medium", mod: mod})

    %{
      "data" => %{
        "updateModValue" => %{
          "successful" => false,
          "messages" => [
            error
          ]
        }
      }
    } =
      update_mod_value(conn, %{
        id: medium,
        mod: mod,
        value: "small"
      })

    assert "value" == error["field"]
    assert "already exists" == error["message"]
  end

  test "delete a mod value that does not exist", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "deleteModValue" => %{
          "successful" => false,
          "messages" => [
            error
          ]
        }
      }
    } = delete_mod_value(conn, "1")

    assert "mod value not found" == error["message"]
  end

  test "delete a mod value", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "createMod" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => mod,
            "name" => "tshirt-size"
          }
        }
      }
    } = create_mod(conn, %{name: "tshirt-size", description: "T-Shirt sizes", type: "select"})

    %{
      "data" => %{
        "createModValue" => %{
          "successful" => true,
          "result" => %{
            "id" => id
          }
        }
      }
    } = create_mod_value(conn, %{value: "small", mod: mod})

    assert count_mod_values(conn) ==
             %{"data" => %{"countModValues" => 1}}

    %{
      "data" => %{
        "deleteModValue" => %{
          "successful" => true
        }
      }
    } = delete_mod_value(conn, id)

    assert count_mod_values(conn) ==
             %{"data" => %{"countModValues" => 0}}
  end
end
