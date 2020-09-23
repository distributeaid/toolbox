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

  # test "create mod with invalid data", %{conn: conn} do
  #   insert(:user)
  #   |> mock_sign_in

  #   %{
  #     "data" => %{
  #       "createMod" => %{
  #         "successful" => false,
  #         "messages" => [
  #           %{"field" => "name", "message" => "can't be blank"}
  #         ]
  #       }
  #     }
  #   } = create_mod(conn, %{name: "", description: "some description", type: "select"})
  # end

  # test "fetch a mod that does not exist", %{conn: conn} do
  #   %{
  #     "data" => %{
  #       "modByName" => nil
  #     },
  #     "errors" => [error]
  #   } = get_mod_by_name(conn, "test")

  #   assert "mod not found" == error["message"]
  # end

  # test "update a mod that does not exist", %{conn: conn} do
  #   insert(:user)
  #   |> mock_sign_in

  #   %{
  #     "data" => %{
  #       "updateMod" => %{
  #         "successful" => false,
  #         "messages" => [
  #           error
  #         ]
  #       }
  #     }
  #   } =
  #     update_mod(conn, %{
  #       id: 123,
  #       name: "some name"
  #     })

  #   assert "mod not found" == error["message"]
  # end

  # test "update existing mod", %{conn: conn} do
  #   insert(:user)
  #   |> mock_sign_in

  #   %{
  #     "data" => %{
  #       "createMod" => %{
  #         "successful" => true,
  #         "result" => %{
  #           "id" => id
  #         }
  #       }
  #     }
  #   } = create_mod(conn, %{name: "size", description: "sizes", type: "select"})

  #   %{
  #     "data" => %{
  #       "updateMod" => %{
  #         "successful" => true,
  #         "result" => %{
  #           "id" => ^id,
  #           "name" => "sizes"
  #         }
  #       }
  #     }
  #   } =
  #     update_mod(conn, %{
  #       id: id,
  #       name: "sizes"
  #     })
  # end

  # test "update mod with invalid data", %{conn: conn} do
  #   insert(:user)
  #   |> mock_sign_in

  #   %{
  #     "data" => %{
  #       "createMod" => %{
  #         "successful" => true
  #       }
  #     }
  #   } = create_mod(conn, %{name: "sizes", description: "sizes", type: "select"})

  #   %{
  #     "data" => %{
  #       "createMod" => %{
  #         "successful" => true,
  #         "result" => %{
  #           "id" => id2
  #         }
  #       }
  #     }
  #   } = create_mod(conn, %{name: "size", description: "size", type: "select"})

  #   %{
  #     "data" => %{
  #       "updateMod" => %{
  #         "successful" => false
  #       }
  #     }
  #   } =
  #     update_mod(conn, %{
  #       id: id2,
  #       name: "sizes"
  #     })
  # end

  # test "delete a mod that does not exist", %{conn: conn} do
  #   insert(:user)
  #   |> mock_sign_in

  #   %{
  #     "data" => %{
  #       "deleteMod" => %{
  #         "successful" => false,
  #         "messages" => [
  #           error
  #         ]
  #       }
  #     }
  #   } = delete_mod(conn, 123)

  #   assert "mod not found" == error["message"]
  # end

  # test "delete a mod", %{conn: conn} do
  #   insert(:user)
  #   |> mock_sign_in

  #   %{
  #     "data" => %{
  #       "createMod" => %{
  #         "successful" => true,
  #         "result" => %{
  #           "id" => id
  #         }
  #       }
  #     }
  #   } = create_mod(conn, %{name: "sizes", description: "sizes", type: "select"})

  #   assert count_mods(conn) ==
  #            %{"data" => %{"countMods" => 1}}

  #   %{
  #     "data" => %{
  #       "deleteMod" => %{
  #         "successful" => true
  #       }
  #     }
  #   } = delete_mod(conn, id)

  #   assert count_mods(conn) ==
  #            %{"data" => %{"countMods" => 0}}
  # end
end
