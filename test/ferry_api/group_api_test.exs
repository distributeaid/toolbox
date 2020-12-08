defmodule Ferry.GroupApiTest do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.Group

  describe "any user" do
    test "can count groups", %{conn: conn} do
      %{"data" => %{"countGroups" => count}} = count_groups(conn)
      # The default distribute aid group
      assert count == 1
    end

    test "can get all groups", %{conn: conn} do
      %{"data" => %{"groups" => [%{"name" => "DistributeAid"}]}} = get_groups(conn)
    end

    test "can fetch a single group", %{conn: conn} do
      %{"data" => %{"group" => %{"name" => "DistributeAid"}}} = get_group(conn, 0)
    end

    test "gets a proper error when trying to fetch a non existing group", %{conn: conn} do
      %{
        "errors" => [
          %{
            "message" => "group not found"
          }
        ]
      } = get_group(conn, 161)
    end
  end

  describe "any authenticated user" do
    setup context do
      Ferry.Fixture.GroupUserRole.setup(
        context,
        %{
          group: "group",
          user: "user@group",
          role: "admin"
        },
        auth: true
      )
    end

    test "gets a proper error when creating a group with invalid data", %{conn: conn} do
      %{
        "data" => %{
          "createGroup" => %{
            "successful" => false,
            "messages" => [
              %{
                "field" => "name",
                "message" => "can't be blank"
              },
              %{
                "field" => "slug",
                "message" => "can't be blank"
              }
            ]
          }
        }
      } = create_invalid_group(conn, params_for(:invalid_group))
    end

    test "gets a proper error when updating a group with invalid data", %{
      conn: conn,
      group: group
    } do
      %{
        "data" => %{
          "updateGroup" => %{
            "successful" => false,
            "messages" => [
              %{
                "field" => "name",
                "message" => "can't be blank"
              }
            ]
          }
        }
      } = update_group(conn, %{id: group.id, name: ""})
    end
  end

  describe "anonymous user" do
    setup context do
      Ferry.Fixture.GroupUserRole.setup(context, %{
        group: "group",
        user: "user@group",
        role: "member"
      })
    end

    test "cannot create groups", %{conn: conn} do
      %{
        "data" => %{
          "createGroup" => %{
            "successful" => false,
            "messages" => [
              %{"message" => "unauthorized"}
            ]
          }
        }
      } = create_simple_group(conn, %{name: "group"})
    end

    test "cannot update a group", %{conn: conn, group: group} do
      %{
        "data" => %{
          "updateGroup" => %{
            "successful" => false,
            "messages" => [
              %{"message" => "unauthorized"}
            ]
          }
        }
      } = update_group(conn, %{id: group.id})
    end

    test "cannot delete a group", %{conn: conn, group: group} do
      %{
        "data" => %{
          "deleteGroup" => %{
            "successful" => false,
            "messages" => [
              %{"message" => "unauthorized"}
            ]
          }
        }
      } = delete_group(conn, group.id)
    end
  end

  describe "distribute aid admin" do
    setup context do
      Ferry.Fixture.DistributeAid.setup(context, auth: true)
    end

    test "can create a group", %{conn: conn} do
      %{
        "data" => %{
          "createGroup" => %{
            "successful" => true
          }
        }
      } = create_simple_group(conn, %{name: "group"})
    end

    test "can update a group", %{conn: conn} do
      %{
        "data" => %{
          "updateGroup" => %{
            "successful" => true
          }
        }
      } = update_group(conn, %{id: 0})
    end

    test "can delete any standard group", %{conn: conn} = context do
      {:ok, %{group: group}} =
        Ferry.Fixture.Group.setup(
          context,
          %{
            group: "group"
          }
        )

      %{
        "data" => %{
          "deleteGroup" => %{
            "successful" => true
          }
        }
      } = delete_group(conn, group.id)
    end

    test "cannot delete a group that has members", %{conn: conn} = context do
      {:ok, %{group: group}} =
        Ferry.Fixture.GroupUserRole.setup(context, %{
          group: "group",
          user: "user@group",
          role: "member"
        })

      %{
        "data" => %{
          "deleteGroup" => %{
            "successful" => false,
            "messages" => [
              %{"message" => "group has users"}
            ]
          }
        }
      } = delete_group(conn, group.id)
    end

    test "cannot delete the distribute aid group", %{conn: conn} do
      %{
        "data" => %{
          "deleteGroup" => %{
            "successful" => false,
            "messages" => [
              %{"message" => "unauthorized"}
            ]
          }
        }
      } = delete_group(conn, 0)
    end
  end

  describe "group admin" do
    setup context do
      Ferry.Fixture.GroupUserRole.setup(
        context,
        %{
          group: "group",
          user: "admin@group",
          role: "admin"
        },
        auth: true
      )
    end

    test "can create a group", %{conn: conn} do
      %{
        "data" => %{
          "createGroup" => %{
            "successful" => true
          }
        }
      } = create_simple_group(conn, %{name: "group2"})
    end

    test "can update a group she/he belongs to", %{conn: conn, group: group} do
      %{
        "data" => %{
          "updateGroup" => %{
            "successful" => true
          }
        }
      } = update_group(conn, %{id: group.id})
    end

    test "cannot update a group she/he does not belong to", %{conn: conn} = context do
      {:ok, %{group: group2}} =
        Ferry.Fixture.Group.setup(
          context,
          %{
            group: "group2"
          }
        )

      %{
        "data" => %{
          "updateGroup" => %{
            "successful" => false,
            "messages" => [
              %{"message" => "unauthorized"}
            ]
          }
        }
      } = update_group(conn, %{id: group2.id})
    end

    test "cannot delete a group she/he does not belong to", %{conn: conn} = context do
      {:ok, %{group: group2}} =
        Ferry.Fixture.Group.setup(
          context,
          %{
            group: "group2"
          }
        )

      %{
        "data" => %{
          "deleteGroup" => %{
            "successful" => false,
            "messages" => [
              %{"message" => "unauthorized"}
            ]
          }
        }
      } = delete_group(conn, group2.id)
    end

    test "cannot delete a group where she/he belongs that has members",
         %{conn: conn, group: group} = context do
      {:ok, _} =
        Ferry.Fixture.UserRole.setup(context, %{
          group: group.name,
          user: "member@group",
          role: "member"
        })

      %{
        "data" => %{
          "deleteGroup" => %{
            "successful" => false,
            "messages" => [
              %{"message" => "group has users"}
            ]
          }
        }
      } = delete_group(conn, group.id)
    end
  end
end
