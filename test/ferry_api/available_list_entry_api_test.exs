defmodule Ferry.AvailableListEntryApiTest do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.{AvailableList, AvailableListEntry}

  setup context do
    {:ok, context} = Ferry.Fixture.DistributeAid.setup(context, auth: true)
    Ferry.Fixture.AvailableListWithEntry.setup(context)
  end

  describe "available list entry graphql api" do
    test "available list also returns its entries", %{conn: conn, available: id, entry: entry} do
      %{
        "data" => %{
          "availableList" => %{
            "id" => ^id,
            "entries" => [%{"id" => ^entry}]
          }
        }
      } = get_available_list(conn, id)
    end

    test "creates available list entries", %{conn: conn, available: id, item: item} do
      %{
        "data" => %{
          "createAvailableListEntry" => %{
            "successful" => true,
            "messages" => [],
            "result" => %{
              "id" => _,
              "amount" => 1,
              "item" => %{"id" => ^item},
              "list" => %{"id" => ^id}
            }
          }
        }
      } =
        create_available_list_entry(conn, %{
          list: id,
          item: item,
          amount: 1
        })

      %{
        "data" => %{
          "availableList" => %{
            "id" => ^id,
            "entries" => [_, _]
          }
        }
      } = get_available_list(conn, id)
    end

    test "deletes available list entries", %{conn: conn, available: id, entry: entry} do
      %{
        "data" => %{
          "deleteAvailableListEntry" => %{
            "successful" => true,
            "messages" => [],
            "result" => %{
              "id" => _
            }
          }
        }
      } = delete_available_list_entry(conn, entry)

      %{
        "data" => %{
          "availableList" => %{
            "id" => ^id,
            "entries" => []
          }
        }
      } = get_available_list(conn, id)
    end

    test "updates an available list entry amount", %{
      conn: conn,
      available: id,
      item: item,
      entry: entry
    } do
      %{
        "data" => %{
          "updateAvailableListEntry" => %{
            "successful" => true,
            "messages" => [],
            "result" => %{
              "id" => _
            }
          }
        }
      } =
        update_available_list_entry(conn, %{
          id: entry,
          list: id,
          item: item,
          amount: 2
        })

      %{
        "data" => %{
          "availableList" => %{
            "id" => ^id,
            "entries" => [%{"amount" => 2}]
          }
        }
      } = get_available_list(conn, id)

      %{
        "data" => %{
          "availableListEntry" => %{
            "id" => ^entry,
            "list" => %{
              "id" => ^id
            },
            "amount" => 2
          }
        }
      } = get_available_list_entry(conn, entry)
    end
  end
end
