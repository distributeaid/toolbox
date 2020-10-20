defmodule Ferry.Fixture.GroupProjectAddress do
  import Ferry.ApiClient.{Group, Project, Address}

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
        "createGroup" => %{
          "successful" => true,
          "result" => %{
            "id" => other_group
          }
        }
      }
    } = create_simple_group(conn, %{name: "other group"})

    %{
      "data" => %{
        "createProject" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => project,
            "name" => "test project",
            "description" => "test description for test project"
          }
        }
      }
    } =
      create_project(conn, %{
        group: group,
        name: "test project",
        description: "test description for test project"
      })

    %{
      "data" => %{
        "createAddress" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => address
          }
        }
      }
    } = create_address(conn, %{group: group, label: "test"})

    %{
      "data" => %{
        "createAddress" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => other_address
          }
        }
      }
    } = create_address(conn, %{group: other_group, label: "test"})

    context =
      Map.merge(context, %{
        group: group,
        project: project,
        address: address,
        other_address: other_address
      })

    {:ok, context}
  end
end
