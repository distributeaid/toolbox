defmodule Ferry.NeedsListEntryApiTest do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.{NeedsList, NeedsListEntry}

  setup context do
    {:ok, context} = Ferry.Fixture.DistributeAid.setup(context, auth: true)
    Ferry.Fixture.NeedsListWithEntry.setup(context)
  end

  describe "needs list entry graphql api" do
    test "needs list also returns its entries", %{conn: conn, needs: needs, entry: entry} do
      %{
        "data" => %{
          "needsList" => %{
            "id" => ^needs,
            "entries" => [%{"id" => ^entry}]
          }
        }
      } = get_needs_list(conn, needs)
    end

    test "creates need list entries", %{conn: conn, needs: needs, item: item} do
      %{
        "data" => %{
          "createNeedsListEntry" => %{
            "successful" => true,
            "messages" => [],
            "result" => %{
              "id" => _,
              "amount" => 1,
              "item" => %{"id" => ^item},
              "list" => %{"id" => ^needs}
            }
          }
        }
      } =
        create_needs_list_entry(conn, %{
          list: needs,
          item: item,
          amount: 1
        })

      %{
        "data" => %{
          "needsList" => %{
            "id" => ^needs,
            "entries" => [_, _]
          }
        }
      } = get_needs_list(conn, needs)

      # try to create the same entry again. It
      # still should create it. Let the administrator
      # fix this in the UI.
      %{
        "data" => %{
          "createNeedsListEntry" => %{
            "successful" => true,
            "messages" => [],
            "result" => %{
              "id" => _,
              "amount" => 1,
              "item" => %{"id" => ^item},
              "list" => %{"id" => ^needs}
            }
          }
        }
      } =
        create_needs_list_entry(conn, %{
          list: needs,
          item: item,
          amount: 1
        })

      %{
        "data" => %{
          "needsList" => %{
            "id" => ^needs,
            "entries" => [_, _, _]
          }
        }
      } = get_needs_list(conn, needs)
    end

    test "deletes needs list entries", %{conn: conn, needs: needs, entry: entry} do
      %{
        "data" => %{
          "deleteNeedsListEntry" => %{
            "successful" => true,
            "messages" => [],
            "result" => %{
              "id" => _
            }
          }
        }
      } = delete_needs_list_entry(conn, entry)

      %{
        "data" => %{
          "needsList" => %{
            "id" => ^needs,
            "entries" => []
          }
        }
      } = get_needs_list(conn, needs)
    end

    test "updates an needs list entry amount", %{
      conn: conn,
      needs: needs,
      item: item,
      entry: entry
    } do
      %{
        "data" => %{
          "updateNeedsListEntry" => %{
            "successful" => true,
            "messages" => [],
            "result" => %{
              "id" => _
            }
          }
        }
      } =
        update_needs_list_entry(conn, %{
          id: entry,
          list: needs,
          item: item,
          amount: 2
        })

      %{
        "data" => %{
          "needsList" => %{
            "id" => ^needs,
            "entries" => [%{"amount" => 2}]
          }
        }
      } = get_needs_list(conn, needs)

      %{
        "data" => %{
          "needsListEntry" => %{
            "id" => ^entry,
            "list" => %{
              "id" => ^needs
            },
            "amount" => 2
          }
        }
      } = get_needs_list_entry(conn, entry)
    end
  end
end
