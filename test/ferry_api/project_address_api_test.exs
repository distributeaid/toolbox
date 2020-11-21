defmodule Ferry.ProjectAddressApiTest do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.Address

  setup context do
    {:ok, context} = Ferry.Fixture.DistributeAid.setup(context, auth: true)

    Ferry.Fixture.GroupProjectAddress.setup(context)
  end

  test "adds address to project", %{conn: conn, project: project, address: address} do
    %{
      "data" => %{
        "addAddressToProject" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => ^project,
            "addresses" => [
              %{"id" => ^address}
            ]
          }
        }
      }
    } = add_address_to_project(conn, project, address)
  end

  test "does not add an address that does not belong to the group", %{
    conn: conn,
    project: project,
    other_address: address
  } do
    %{
      "data" => %{
        "addAddressToProject" => %{
          "successful" => false,
          "messages" => [error]
        }
      }
    } = add_address_to_project(conn, project, address)

    assert "address does not belong to the project's group" == error["message"]
  end

  test "removes address from project", %{conn: conn, project: project, address: address} do
    %{
      "data" => %{
        "addAddressToProject" => %{
          "successful" => true,
          "messages" => []
        }
      }
    } = add_address_to_project(conn, project, address)

    %{
      "data" => %{
        "removeAddressFromProject" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "addresses" => []
          }
        }
      }
    } = remove_address_from_project(conn, project, address)

    %{
      "data" => %{
        "removeAddressFromProject" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "addresses" => []
          }
        }
      }
    } = remove_address_from_project(conn, project, address)
  end
end
