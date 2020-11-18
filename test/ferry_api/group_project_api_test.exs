defmodule Ferry.GroupProjectApiTest do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.{Group, Project}

  test "fetch a group and its projects", %{conn: conn} do
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

    # create a project for that group
    %{
      "data" => %{
        "createProject" => %{
          "successful" => true,
          "result" => %{
            "id" => id
          }
        }
      }
    } =
      create_project(conn, %{
        group: group,
        name: "test project",
        description: "test description for test project"
      })

    # verify we can get that group and its projects
    %{
      "data" => %{
        "group" => %{
          "projects" => [
            %{"id" => ^id}
          ]
        }
      }
    } = get_group_with_projects(conn, group)

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

    # verify that group has no projects
    %{
      "data" => %{
        "group" => %{
          "projects" => []
        }
      }
    } = get_group_with_projects(conn, group)

    # verify we can get both groups and their associated
    # projects

    %{
      "data" => %{
        "groups" => [
          # built-in group
          %{"name" => "DistributeAid"},
          %{
            "name" => "first group",
            "projects" => [
              %{"name" => "test project"}
            ]
          },
          %{
            "name" => "second group",
            "projects" => []
          }
        ]
      }
    } = get_groups_with_projects(conn)
  end
end
