defmodule Ferry.AvailableListApiTest do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.AvailableList

  setup context do
    {:ok, context} = Ferry.Fixture.DistributeAid.setup(context, auth: true)
    Ferry.Fixture.AvailableListWithEntry.setup(context)
  end

  describe "available list graphql api" do
    test "returns all available lists for an address", %{
      conn: conn,
      address: address,
      available: id
    } do
      %{
        "data" => %{
          "availableLists" => [
            %{"id" => ^id}
          ]
        }
      } =
        get_available_lists(conn, %{
          address: address
        })
    end

    test "fetches a single available list", %{conn: conn, available: id} do
      %{
        "data" => %{
          "availableList" => %{"id" => ^id}
        }
      } = get_available_list(conn, id)
    end

    test "deletes an available list", %{conn: conn, address: address, available: id} do
      %{
        "data" => %{
          "deleteAvailableList" => %{
            "successful" => true
          }
        }
      } = delete_available_list(conn, id)

      %{
        "data" => %{
          "availableLists" => []
        }
      } =
        get_available_lists(conn, %{
          address: address
        })

      %{
        "data" => %{
          "availableList" => nil
        }
      } = get_available_list(conn, id)
    end
  end
end
