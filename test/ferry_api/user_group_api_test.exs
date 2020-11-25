defmodule Ferry.UserGroupApiTest do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.User

  describe "distributeaid admin" do
    test "can set or delete the role for any existing user in any group",
         %{conn: conn} = context do
      # setup the distribute aid group and admin user
      {:ok, %{distributeaid: %{user: admin}}} = Ferry.Fixture.DistributeAid.setup(context)

      # Set a standard group and user
      {:ok, %{group: group, user: user}} =
        Ferry.Fixture.GroupUserRole.setup(context, %{
          group: "group",
          user: "user@group",
          role: "member"
        })

      # Authenticate as distribute aid admin
      conn = auth(conn, admin)

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
    test "can set and delete the role of existing users in that group",
         %{conn: conn} = context do
      # Sets up some aid group and its admin user
      {:ok, %{user: admin, group: group}} =
        Ferry.Fixture.GroupUserRole.setup(context, %{
          group: "group",
          user: "admin@group",
          role: "admin"
        })

      # Add a new user to the system
      {:ok, member} = Ferry.Accounts.create_user(%{email: "member@group"})

      # Authenticate as the group admin
      conn = auth(conn, admin)

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

      # For consistent, fetch that user and verify it no longer
      # belongs to that group
      %{
        "data" => %{
          "user" => %{
            "groups" => []
          }
        }
      } = get_user(conn, member.id)
    end

    test "cannot set the role of existing users in other groups", %{conn: conn} = context do
      # Sets up some aid group and its admin user
      {:ok, %{user: admin}} =
        Ferry.Fixture.GroupUserRole.setup(context, %{
          group: "group",
          user: "admin@group",
          role: "admin"
        })

      # Set up a different group group and its admin user
      {:ok, %{group: group2}} =
        Ferry.Fixture.GroupUserRole.setup(context, %{
          group: "group2",
          user: "admin@group2",
          role: "admin"
        })

      # Add a new user to the system
      {:ok, member} = Ferry.Accounts.create_user(%{email: "member@group2"})

      # Authenticate as the admin in the first group
      conn = auth(conn, admin)

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
      assert [] == member.groups
    end
  end
end
