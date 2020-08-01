defmodule Ferry.ModSchemaTest do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.Mod

  test "count mods where there are none", %{conn: conn} do
    assert count_mods(conn) ==
             %{"data" => %{"countMods" => 0}}
  end

  test "get all mods where there are none", %{conn: conn} do
    assert get_mods(conn) == %{"data" => %{"mods" => []}}
  end

  # test "create one mod", %{conn: conn} do
  #   insert(:user)
  #   |> mock_sign_in

  #   %{
  #     "data" => %{
  #       "createMod" => %{
  #         "successful" => true,
  #         "messages" => [],
  #         "result" => %{
  #           "id" => id,
  #           "name" => "test"
  #         }
  #       }
  #     }
  #   } = create_mod(conn, %{name: "test"})

  #   #   assert id

  #   # verify that mod is returned in the collection
  #   # of all mods
  #   assert count_mods(conn) ==
  #            %{"data" => %{"countMods" => 1}}

  #   %{"data" => %{"mods" => [cat]}} = get_mods(conn)

  #   assert cat["id"]
  #   assert "test" == cat["name"]

  #   # verify we can fetch that mod given its id
  #   %{
  #     "data" => %{
  #       "mod" => ^cat
  #     }
  #   } = get_mod(conn, cat["id"])
  # end

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
  #   } = create_mod(conn, %{name: ""})
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
  #   } = create_mod(conn, %{name: "test"})

  #   %{
  #     "data" => %{
  #       "updateMod" => %{
  #         "successful" => true,
  #         "result" => %{
  #           "id" => ^id,
  #           "name" => "new name"
  #         }
  #       }
  #     }
  #   } =
  #     update_mod(conn, %{
  #       id: id,
  #       name: "new name"
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
  #   } = create_mod(conn, %{name: "test"})

  #   %{
  #     "data" => %{
  #       "createMod" => %{
  #         "successful" => true,
  #         "result" => %{
  #           "id" => id2
  #         }
  #       }
  #     }
  #   } = create_mod(conn, %{name: "test2"})

  #   %{
  #     "data" => %{
  #       "updateMod" => %{
  #         "successful" => false
  #       }
  #     }
  #   } =
  #     update_mod(conn, %{
  #       id: id2,
  #       name: "test"
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
  #   } = create_mod(conn, %{name: "test"})

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
