defmodule Ferry.GroupAddressApiTest do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.Group
  import Ferry.ApiClient.Address

  test "fetch a group and its addresses", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    # create a group
    group_attrs = params_for(:group) |> with_address()
    group_attrs = %{group_attrs | name: "first group"}

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

    # add an address to that group
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

    # verify we can get that group and its addresses
    %{
      "data" => %{
        "group" => %{
          "addresses" => [
            %{"id" => ^id}
          ]
        }
      }
    } = get_group_with_addresses(conn, group)

    # create a second group with no projects
    group_attrs = params_for(:group) |> with_address()
    group_attrs = %{group_attrs | name: "second group"}

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

    # verify that group has a single address
    %{
      "data" => %{
        "group" => %{
          "addresses" => []
        }
      }
    } = get_group_with_addresses(conn, group)

    # verify we can get both groups and their associated
    # projects

    %{
      "data" => %{
        "groups" => [
          %{
            "name" => "DistributeAid"
          },
          %{
            "name" => "first group",
            "addresses" => [
              %{"label" => "test"}
            ]
          },
          %{
            "name" => "second group",
            "addresses" => []
          }
        ]
      }
    } = get_groups_with_addresses(conn)
  end
end
