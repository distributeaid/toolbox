defmodule Ferry.UserGroupApiTest do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.User

  describe "anonymous user" do
    setup context do
      # Setup a standard group and user
      # so that we can test the access that anonymous
      # users have on them
      Ferry.Fixture.GroupUserRole.setup(context, %{
        group: "group",
        user: "user@group",
        role: "member"
      })
    end

    test "cannot count users", %{conn: conn} do
      %{
        "errors" => [
          %{"message" => "unauthorized"}
        ]
      } = count_users(conn)
    end

    test "cannot to list users", %{conn: conn} do
      %{
        "errors" => [
          %{"message" => "unauthorized"}
        ]
      } = get_users(conn)
    end

    test "cannot fetch a single user", %{conn: conn, user: user} do
      %{
        "errors" => [
          %{"message" => "unauthorized"}
        ]
      } = get_user(conn, user.id)
    end

    test "are not authorized to set or delete a user role", %{
      conn: conn,
      user: user,
      group: group
    } do
      %{
        "data" => %{
          "setUserRole" => %{
            "successful" => false,
            "messages" => [
              %{"message" => "unauthorized"}
            ]
          }
        }
      } =
        set_user_role(conn, %{
          user: user.id,
          group: group.id,
          role: "admin"
        })

      %{
        "data" => %{
          "deleteUserRole" => %{
            "successful" => false,
            "messages" => [
              %{"message" => "unauthorized"}
            ]
          }
        }
      } =
        delete_user_role(conn, %{
          user: user.id,
          group: group.id,
          role: "admin"
        })
    end
  end

  describe "distributeaid admin" do
    setup context do
      # Setup a distribute aid admin and authenticate
      # the current connection
      Ferry.Fixture.DistributeAid.setup(context, auth: true)
    end

    test "can count users", %{conn: conn} do
      assert %{"data" => %{"countUsers" => 1}} == count_users(conn)
    end

    test "can list users from any group", %{conn: conn} = context do
      assert %{"data" => %{"countUsers" => 1}} == count_users(conn)

      {:ok, _} =
        Ferry.Fixture.GroupUserRole.setup(context, %{
          group: "group",
          user: "user@group",
          role: "member"
        })

      assert %{"data" => %{"countUsers" => 2}} == count_users(conn)

      %{"data" => %{"users" => users}} = get_users(conn)

      assert 2 == length(users)
    end

    test "can fetch any user from any group", %{conn: conn} = context do
      {:ok, %{user: member}} =
        Ferry.Fixture.GroupUserRole.setup(context, %{
          group: "group",
          user: "user@group",
          role: "member"
        })

      %{
        "data" => %{
          "user" => user
        }
      } = get_user(conn, member.id)

      assert user["id"] == "#{member.id}"
    end

    test "can set or delete the role for any existing user in any group",
         %{conn: conn} = context do
      # Set a standard group and user
      {:ok, %{group: group, user: user}} =
        Ferry.Fixture.GroupUserRole.setup(context, %{
          group: "group",
          user: "user@group",
          role: "member"
        })

      # This user now becomes an admin
      %{
        "data" => %{
          "setUserRole" => %{
            "successful" => true,
            "messages" => [],
            "result" => %{
              "email" => "user@group",
              "groups" => [
                %{
                  "role" => role,
                  "group" => group
                }
              ]
            }
          }
        }
      } =
        set_user_role(conn, %{
          user: user.id,
          group: group.id,
          role: "admin"
        })

      assert "admin" == role
      assert "group" == group["name"]

      # Now delete that role
      %{
        "data" => %{
          "deleteUserRole" => %{
            "successful" => true,
            "messages" => [],
            "result" => %{
              "email" => "user@group",
              "groups" => []
            }
          }
        }
      } =
        delete_user_role(conn, %{
          user: user.id,
          group: group["id"],
          role: "admin"
        })

      # For consistent, fetch that user and verify it no longer
      # belongs to that group
      %{
        "data" => %{
          "user" => %{
            "groups" => []
          }
        }
      } = get_user(conn, user.id)
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

    test "can only count users from groups they belong to", %{conn: conn} = context do
      assert %{"data" => %{"countUsers" => 1}} == count_users(conn)

      {:ok, _} =
        Ferry.Fixture.UserRole.setup(context, %{
          group: "group",
          user: "user@group",
          role: "member"
        })

      assert %{"data" => %{"countUsers" => 2}} == count_users(conn)

      {:ok, _} =
        Ferry.Fixture.GroupUserRole.setup(context, %{
          group: "group2",
          user: "user@group2",
          role: "member"
        })

      assert %{"data" => %{"countUsers" => 2}} == count_users(conn)
    end

    test "can only list users from groups they belong to", %{conn: conn} = context do
      assert %{"data" => %{"countUsers" => 1}} == count_users(conn)

      {:ok, _} =
        Ferry.Fixture.UserRole.setup(context, %{
          group: "group",
          user: "user@group",
          role: "member"
        })

      %{"data" => %{"users" => users}} = get_users(conn)
      assert 2 == length(users)

      {:ok, _} =
        Ferry.Fixture.GroupUserRole.setup(context, %{
          group: "group2",
          user: "user@group2",
          role: "member"
        })

      %{"data" => %{"users" => users}} = get_users(conn)
      assert 2 == length(users)
    end

    test "can fetch a single user from the same group", %{conn: conn} = context do
      {:ok, %{user: member}} =
        Ferry.Fixture.UserRole.setup(context, %{
          group: "group",
          user: "user@group",
          role: "member"
        })

      %{
        "data" => %{
          "user" => user
        }
      } = get_user(conn, member.id)

      assert user["id"] == "#{member.id}"
    end

    test "cannot fetch a single user from a different group", %{conn: conn} = context do
      {:ok, %{user: member}} =
        Ferry.Fixture.GroupUserRole.setup(context, %{
          group: "group2",
          user: "user@group2",
          role: "member"
        })

      %{
        "errors" => [
          %{"message" => "unauthorized"}
        ]
      } = get_user(conn, member.id)
    end

    test "can set and delete the role of existing users in that group",
         %{conn: conn, group: group} = context do
      {:ok, %{user: member}} =
        Ferry.Fixture.UserRole.setup(context, %{
          group: "group",
          user: "member@group",
          role: "member"
        })

      # The member now becomes an admin
      %{
        "data" => %{
          "setUserRole" => %{
            "successful" => true,
            "messages" => [],
            "result" => %{
              "email" => "member@group",
              "groups" => [
                %{
                  "role" => role,
                  "group" => group
                }
              ]
            }
          }
        }
      } =
        set_user_role(conn, %{
          user: member.id,
          group: group.id,
          role: "admin"
        })

      assert "admin" == role
      assert "group" == group["name"]

      # For consistency, fetch that user and verify it has that role
      # in that group
      %{
        "data" => %{
          "user" => %{
            "groups" => [
              membership
            ]
          }
        }
      } = get_user(conn, member.id)

      assert "admin" == membership["role"]
      assert "group" == membership["group"]["name"]

      # Now delete that role
      %{
        "data" => %{
          "deleteUserRole" => %{
            "successful" => true,
            "messages" => [],
            "result" => %{
              "email" => "member@group",
              "groups" => []
            }
          }
        }
      } =
        delete_user_role(conn, %{
          user: member.id,
          group: group["id"],
          role: "admin"
        })

      # Check the membership was deleted
      {:ok, member} = Ferry.Accounts.get_user(member.id)
      [] = member.groups

      # Since we deleted that role in that group,
      # we no longer have access to that user
      %{
        "errors" => [
          %{"message" => "unauthorized"}
        ]
      } = get_user(conn, member.id)
    end

    test "cannot set the role of existing users in other groups", %{conn: conn} = context do
      # Set up a different group group and its admin user
      {:ok, %{user: member, group: group2}} =
        Ferry.Fixture.GroupUserRole.setup(context, %{
          group: "group2",
          user: "member@group2",
          role: "member"
        })

      # Attempt to change the role of user in the second group
      %{
        "data" => %{
          "setUserRole" => %{
            "successful" => false,
            "messages" => [
              %{"message" => "unauthorized"}
            ]
          }
        }
      } =
        set_user_role(conn, %{
          user: member.id,
          group: group2.id,
          role: "admin"
        })

      # Verify the role hasnt changed
      {:ok, member} = Ferry.Accounts.get_user(member.id)
      [membership] = member.groups
      assert "member" == membership.role
      assert group2.id == membership.group.id
    end
  end
end
