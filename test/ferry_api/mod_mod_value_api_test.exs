defmodule Ferry.ModModValueApiTest do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.{Mod, ModValue}

  setup context do
    Ferry.Fixture.DistributeAid.setup(context, auth: true)
  end

  test "can't delete a mod that has mod values", %{conn: conn} do
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
        "deleteMod" => %{
          "successful" => false,
          "messages" => [
            error
          ]
        }
      }
    } = delete_mod(conn, mod)

    assert "id" == error["field"]
    assert "has mod values" = error["message"]

    %{
      "data" => %{
        "deleteModValue" => %{
          "successful" => true
        }
      }
    } = delete_mod_value(conn, id)

    assert count_mods(conn) ==
             %{"data" => %{"countMods" => 1}}

    %{
      "data" => %{
        "deleteMod" => %{
          "successful" => true
        }
      }
    } = delete_mod(conn, mod)

    assert count_mods(conn) ==
             %{"data" => %{"countMods" => 0}}
  end

  test "returns a mod and its values", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "createMod" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => tshirt_size,
            "name" => "tshirt-size"
          }
        }
      }
    } = create_mod(conn, %{name: "tshirt-size", description: "tshirt size", type: "select"})

    %{
      "data" => %{
        "createMod" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => tshirt_color,
            "name" => "tshirt-color"
          }
        }
      }
    } = create_mod(conn, %{name: "tshirt-color", description: "tshirt color", type: "select"})

    %{
      "data" => %{
        "createModValue" => %{
          "successful" => true
        }
      }
    } = create_mod_value(conn, %{value: "small", mod: tshirt_size})

    %{
      "data" => %{
        "createModValue" => %{
          "successful" => true
        }
      }
    } = create_mod_value(conn, %{value: "red", mod: tshirt_color})

    %{
      "data" => %{
        "mods" => [%{"values" => [mod_value1]} = mod1, %{"values" => [mod_value2]} = mod2]
      }
    } = get_mods_with_values(conn)

    assert "tshirt-color" == mod1["name"]
    assert "red" == mod_value1["value"]

    assert "tshirt-size" == mod2["name"]
    assert "small" == mod_value2["value"]
  end
end
