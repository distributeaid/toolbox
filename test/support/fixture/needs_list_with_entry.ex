defmodule Ferry.Fixture.NeedsListWithEntry do
  import Ferry.ApiClient.{Group, Project, NeedsList, Category, Item, NeedsListEntry}

  def setup(%{conn: conn} = context) do
    %{
      "data" => %{
        "createGroup" => %{
          "successful" => true,
          "result" => %{
            "id" => group
          }
        }
      }
    } = create_simple_group(conn, %{name: "a group"})

    %{
      "data" => %{
        "createProject" => %{
          "successful" => true,
          "result" => %{
            "id" => project
          }
        }
      }
    } =
      create_project(conn, %{
        group: group,
        name: "a project",
        description: "a project"
      })

    %{
      "data" => %{
        "createNeedsList" => %{
          "successful" => true,
          "result" => %{
            "id" => needs_list
          }
        }
      }
    } =
      create_needs_list(conn, %{
        project: project,
        from: DateTime.utc_now() |> DateTime.add(-1 * 24 * 3600, :second),
        to: DateTime.utc_now() |> DateTime.add(2 * 24 * 3600, :second)
      })

    %{
      "data" => %{
        "createCategory" => %{
          "successful" => true,
          "result" => %{
            "id" => category
          }
        }
      }
    } = create_category(conn, %{name: "clothes"})

    %{
      "data" => %{
        "createItem" => %{
          "successful" => true,
          "result" => %{
            "id" => item
          }
        }
      }
    } =
      create_item(conn, %{
        category: category,
        name: "tshirt"
      })

    %{
      "data" => %{
        "createNeedsListEntry" => %{
          "successful" => true,
          "result" => %{
            "id" => entry
          }
        }
      }
    } =
      create_needs_list_entry(conn, %{
        list: needs_list,
        item: item,
        amount: 1
      })

    {:ok,
     Map.merge(context, %{
       needs: needs_list,
       project: project,
       item: item,
       entry: entry
     })}
  end
end
