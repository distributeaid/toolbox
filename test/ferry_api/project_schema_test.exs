defmodule Ferry.ProjectSchemaTest do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.{Group, Project}

  test "count projects where there are none", %{conn: conn} do
    assert count_projects(conn) ==
             %{"data" => %{"countProjects" => 0}}
  end

  test "get all projects where there are none", %{conn: conn} do
    assert get_projects(conn) == %{"data" => %{"projects" => []}}
  end

  test "create one project", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    group_attrs = params_for(:group) |> with_address()

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

    %{
      "data" => %{
        "createProject" => %{
          "successful" => true,
          "messages" => [],
          "result" => %{
            "id" => id,
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

    assert id

    # verify that project is returned in the collection
    # of all projects
    assert count_projects(conn) ==
             %{"data" => %{"countProjects" => 1}}

    %{"data" => %{"projects" => [project]}} = get_projects(conn)

    project_id = project["id"]
    assert project_id
    assert "test project" == project["name"]

    # verify we can fetch that project given its id
    %{
      "data" => %{
        "project" => ^project
      }
    } = get_project(conn, project["id"])
  end

  test "create project with invalid data", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    group_attrs = params_for(:group) |> with_address()

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

    %{
      "data" => %{
        "createProject" => %{
          "successful" => false,
          "messages" => [
            %{"field" => "name", "message" => "can't be blank"}
          ]
        }
      }
    } = create_project(conn, %{group: group, name: "", description: "test description"})
  end

  test "fetch a project that does not exist", %{conn: conn} do
    %{
      "data" => %{
        "projectByName" => nil
      },
      "errors" => [error]
    } = get_project_by_name(conn, "test")

    assert "project not found" == error["message"]
  end

  test "update a project that does not exist", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "updateProject" => %{
          "successful" => false,
          "messages" => [
            error
          ]
        }
      }
    } =
      update_project(conn, %{
        id: 123,
        name: "some name",
        description: "new description"
      })

    assert "project not found" == error["message"]
  end

  test "update existing project", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    group_attrs = params_for(:group) |> with_address()

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

    %{
      "data" => %{
        "createProject" => %{
          "successful" => true,
          "result" => %{
            "id" => id
          }
        }
      }
    } = create_project(conn, %{group: group, name: "test", description: "test description"})

    %{
      "data" => %{
        "updateProject" => %{
          "successful" => true,
          "result" => %{
            "id" => ^id,
            "name" => "new name"
          }
        }
      }
    } =
      update_project(conn, %{
        id: id,
        name: "new name",
        description: "new description"
      })
  end

  test "update project with invalid data", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    group_attrs = params_for(:group) |> with_address()

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

    %{
      "data" => %{
        "createProject" => %{
          "successful" => true
        }
      }
    } = create_project(conn, %{group: group, name: "test", description: "test description"})

    %{
      "data" => %{
        "createProject" => %{
          "successful" => true,
          "result" => %{
            "id" => id2
          }
        }
      }
    } = create_project(conn, %{group: group, name: "test2", description: "test description 2"})

    %{
      "data" => %{
        "updateProject" => %{
          "successful" => false
        }
      }
    } =
      update_project(conn, %{
        id: id2,
        name: "test",
        description: "test description"
      })
  end

  test "delete a project that does not exist", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    %{
      "data" => %{
        "deleteProject" => %{
          "successful" => false,
          "messages" => [
            error
          ]
        }
      }
    } = delete_project(conn, 123)

    assert "project not found" == error["message"]
  end

  test "delete a project", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    group_attrs = params_for(:group) |> with_address()

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

    %{
      "data" => %{
        "createProject" => %{
          "successful" => true,
          "result" => %{
            "id" => id
          }
        }
      }
    } = create_project(conn, %{group: group, name: "test", description: "test description"})

    assert count_projects(conn) ==
             %{"data" => %{"countProjects" => 1}}

    %{
      "data" => %{
        "deleteProject" => %{
          "successful" => true
        }
      }
    } = delete_project(conn, id)

    assert count_projects(conn) ==
             %{"data" => %{"countProjects" => 0}}
  end
end
