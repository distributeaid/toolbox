defmodule Ferry.NeedsListApiTest do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.NeedsList

  setup context do
    insert(:user)
    |> mock_sign_in

    Ferry.Fixture.NeedsWithEntry.setup(context)
  end

  describe "needs list graphql api" do
    test "needs lists should not overlap", %{conn: conn, project: project, needs: needs_list} do
      %{
        "data" => %{
          "createNeedsList" => %{
            "successful" => false,
            "messages" => [
              error
            ]
          }
        }
      } =
        create_needs_list(conn, %{
          project: project,
          from: DateTime.utc_now(),
          to: DateTime.utc_now() |> DateTime.add(1 * 24 * 3600, :second)
        })

      assert "needs lists for the same project cannot overlap dates" == error["message"]

      # move the first needs list
      %{
        "data" => %{
          "updateNeedsList" => %{
            "successful" => true
          }
        }
      } =
        update_needs_list(conn, %{
          id: needs_list,
          project: project,
          from: DateTime.utc_now() |> DateTime.add(2 * 24 * 3600, :second),
          to: DateTime.utc_now() |> DateTime.add(4 * 24 * 3600, :second)
        })

      # try to create the needs list again
      %{
        "data" => %{
          "createNeedsList" => %{
            "successful" => true
          }
        }
      } =
        create_needs_list(conn, %{
          project: project,
          from: DateTime.utc_now(),
          to: DateTime.utc_now() |> DateTime.add(1 * 24 * 3600, :second)
        })

      # get all the
    end

    test "returns all needs lists for a project", %{
      conn: conn,
      project: project,
      needs: needs_list
    } do
      %{
        "data" => %{
          "needsLists" => [
            %{"id" => ^needs_list}
          ]
        }
      } =
        get_project_needs_lists(conn, %{
          id: project,
          from: DateTime.utc_now(),
          to: DateTime.utc_now() |> DateTime.add(1 * 24 * 3600, :second)
        })
    end

    test "returns current's needs list for a project", %{
      conn: conn,
      project: project,
      needs: needs_list
    } do
      %{
        "data" => %{
          "currentNeedsList" => %{"id" => ^needs_list}
        }
      } =
        get_project_current_needs_list(conn, %{
          id: project
        })

      # Delete that needs list
      %{
        "data" => %{
          "deleteNeedsList" => %{
            "successful" => true
          }
        }
      } = delete_needs_list(conn, needs_list)

      %{
        "data" => %{
          "currentNeedsList" => nil
        }
      } =
        get_project_current_needs_list(conn, %{
          id: project
        })
    end

    test "fetches a single needs list", %{conn: conn, needs: id} do
      %{
        "data" => %{
          "needsList" => %{"id" => ^id, "from" => _, "to" => _, "project" => %{}}
        }
      } = get_needs_list(conn, id)
    end
  end
end
