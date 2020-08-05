defmodule Ferry.AddressSchemaTest do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.{Group, Address}

  test "count addresses where there are none", %{conn: conn} do
    assert count_addresses(conn) ==
             %{"data" => %{"countAddresses" => 0}}
  end

  test "get all addresses where there are none", %{conn: conn} do
    assert get_addresses(conn) == %{"data" => %{"addresses" => []}}
  end

  test "create one address", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    assert count_addresses(conn) ==
             %{"data" => %{"countAddresses" => 0}}

    group_attrs = params_for(:group) |> with_location()

    %{
      "data" => %{
        "createGroup" => %{
          "successful" => true,
          "result" => %{
            "id" => group
          }
        }
      }
    } = create_group(conn, group_attrs)

    # Verify the group was created, but also
    # an address was created for the group
    assert count_addresses(conn) ==
             %{"data" => %{"countAddresses" => 1}}

    %{
      "data" => %{
        "createAddress" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => id,
            "label" => "test"
          }
        }
      }
    } = create_address(conn, %{group: group, label: "test"})

    assert id

    # verify that address is returned in the collection
    # of all addresses
    assert count_addresses(conn) ==
             %{"data" => %{"countAddresses" => 2}}

    %{"data" => %{"addresses" => [_, address]}} = get_addresses(conn)

    assert address["id"]
    assert id == address["id"]
    assert "test" == address["label"]

    # verify we can fetch that address given its id
    %{
      "data" => %{
        "address" => ^address
      }
    } = get_address(conn, address["id"])
  end

  test "create address with invalid data", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "createAddress" => %{
          "successful" => false,
          "messages" => [
            %{"field" => "name", "message" => "can't be blank"}
          ]
        }
      }
    } = create_address(conn, %{label: ""})
  end

  test "fetch a address that does not exist", %{conn: conn} do
    %{
      "data" => %{
        "address" => nil
      },
      "errors" => [error]
    } = get_address(conn, "123")

    assert "address not found" == error["message"]
  end

  test "update a address that does not exist", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "updateAddress" => %{
          "successful" => false,
          "messages" => [
            error
          ]
        }
      }
    } =
      update_address(conn, %{
        id: 123,
        label: "new label"
      })

    assert "address not found" == error["message"]
  end

  test "update existing address", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "createAddress" => %{
          "successful" => true,
          "result" => %{
            "id" => id
          }
        }
      }
    } = create_address(conn, %{name: "test"})

    %{
      "data" => %{
        "updateAddress" => %{
          "successful" => true,
          "result" => %{
            "id" => ^id,
            "name" => "new name"
          }
        }
      }
    } =
      update_address(conn, %{
        id: id,
        name: "new name"
      })
  end

  test "update address with invalid data", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "createAddress" => %{
          "successful" => true
        }
      }
    } = create_address(conn, %{name: "test"})

    %{
      "data" => %{
        "createAddress" => %{
          "successful" => true,
          "result" => %{
            "id" => id2
          }
        }
      }
    } = create_address(conn, %{name: "test2"})

    %{
      "data" => %{
        "updateAddress" => %{
          "successful" => false
        }
      }
    } =
      update_address(conn, %{
        id: id2,
        name: "test"
      })
  end

  test "delete a address that does not exist", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "deleteAddress" => %{
          "successful" => false,
          "messages" => [
            error
          ]
        }
      }
    } = delete_address(conn, 123)

    assert "address not found" == error["message"]
  end

  test "delete a address", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "createAddress" => %{
          "successful" => true,
          "result" => %{
            "id" => id
          }
        }
      }
    } = create_address(conn, %{name: "test"})

    assert count_addresses(conn) ==
             %{"data" => %{"countAddresses" => 1}}

    %{
      "data" => %{
        "deleteAddress" => %{
          "successful" => true
        }
      }
    } = delete_address(conn, id)

    assert count_addresses(conn) ==
             %{"data" => %{"countAddresses" => 0}}
  end
end
