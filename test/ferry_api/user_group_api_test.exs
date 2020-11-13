defmodule Ferry.UserGroupApiTest do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.User

  describe "distributeaid admin" do
    setup context do
      # Sets up the distributeaid group, and a user that
      # acts as an admin there
      Ferry.Fixture.DistributeAid.setup(context)
    end

    test "distributeaid admin can set the role for any existing user in any group",
         %{conn: conn} = context do
      # Set a standard group and user
      {:ok, %{group: group, user: user}} =
        Ferry.Fixture.GroupUserRole.setup(context, %{
          group: "group",
          user: "user@group",
          role: "member"
        })

      # Authenticate as distribute aid admin
      %{distributeaid: %{user: admin}} = context
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
    end
  end

  describe "group admin" do
    setup context do
      # Sets up some aid, and a user that
      # acts as an admin there
      Ferry.Fixture.GroupUserRole.setup(context, %{
        group: "group",
        user: "admin@group",
        role: "admin"
      })
    end

    test "group admin can set the role of existing users in that group", %{conn: _conn} do
    end

    test "group admin cannot set the role of existing users in other groups", %{conn: _conn} do
    end
  end
end
