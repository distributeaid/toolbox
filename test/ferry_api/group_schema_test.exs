defmodule Ferry.GroupTest do
  use FerryWeb.ConnCase, async: true
  import Ferry.ApiClient.Group
  alias Ferry.Profiles

  # GROUPS
  # ================================================================================

  # Query - Count Groups
  # ------------------------------------------------------------

  test "count groups - none", %{conn: conn} do
    %{"data" => %{"countGroups" => count}} = count_groups(conn)
    assert count == 0
  end

  test "count groups - many", %{conn: conn} do
    insert_list(3, :group)
    %{"data" => %{"countGroups" => count}} = count_groups(conn)
    assert count == 3
  end

  # Query - Get All Groups
  # ------------------------------------------------------------
  test "get all groups - none", %{conn: conn} do
    assert get_groups(conn) == %{"data" => %{"groups" => []}}
  end

  test "get all groups - one", %{conn: conn} do
    group = insert(:group) |> with_location()

    group_params = %{
      "id" => Integer.to_string(group.id),
      "name" => group.name,
      "description" => group.description,
      "location" => %{
        "province" => group.location.province,
        "country_code" => group.location.country_code,
        "postal_code" => group.location.postal_code
      }
    }

    assert get_groups(conn) == %{"data" => %{"groups" => [group_params]}}
  end

  test "get all groups - many", %{conn: conn} do
    groups = insert_pair(:group) |> with_location()

    groups_params =
      Enum.map(groups, fn group ->
        %{
          "id" => Integer.to_string(group.id),
          "name" => group.name,
          "description" => group.description,
          "location" => %{
            "province" => group.location.province,
            "country_code" => group.location.country_code,
            "postal_code" => group.location.postal_code
          }
        }
      end)

    assert get_groups(conn) == %{"data" => %{"groups" => groups_params}}
  end

  # Query - Get A Group
  # ------------------------------------------------------------
  test "get a group - found", %{conn: conn} do
    group = insert(:group) |> with_location()

    group_params = %{
      "id" => Integer.to_string(group.id),
      "name" => group.name,
      "description" => group.description
    }

    assert get_group(conn, group.id) == %{"data" => %{"group" => group_params}}
  end

  test "get a group - no group", %{conn: conn} do
    assert(
      get_group(conn, 161) == %{
        "data" => %{"group" => nil},
        "errors" => [
          %{
            "id" => "161",
            "locations" => [%{"column" => 3, "line" => 2}],
            "message" => "Group not found.",
            "path" => ["group"]
          }
        ]
      }
    )
  end

  # Mutation - Create A Group
  # ------------------------------------------------------------
  test "create a group - success", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    group_attrs = params_for(:group) |> with_location()

    %{
      "data" => %{
        "createGroup" => %{
          "successful" => successful,
          "messages" => messages,
          "result" => %{
            "id" => id,
            "name" => name,
            "slackChannelName" => slack_channel_name,
            "slug" => slug,
            "type" => type,
            "location" => %{
              "province" => province,
              "country_code" => country_code,
              "postal_code" => postal_code
            }
          }
        }
      }
    } = create_group(conn, group_attrs)

    assert successful
    assert messages == []
    assert id
    assert slug == group_attrs.slug
    assert name == group_attrs.name
    assert type == group_attrs.type
    assert slack_channel_name == group_attrs.slack_channel_name
    assert province == group_attrs.location.province
    assert country_code == group_attrs.location.country_code
    assert postal_code == group_attrs.location.postal_code
  end

  test "create a group - error", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    group_attrs = params_for(:invalid_group)

    %{
      "data" => %{
        "createGroup" => %{
          "successful" => successful,
          "messages" => [
            %{
              "field" => field,
              "message" => "can't be blank"
            },
            %{
              "field" => "slug",
              "message" => "can't be blank"
            }
          ],
          "result" => result
        }
      }
    } = create_invalid_group(conn, group_attrs)

    refute successful
    assert field == "name"
    assert result == nil
  end

  # Mutation - Update A Group
  # ------------------------------------------------------------
  test "update a group - success", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    group = insert(:group) |> with_location()
    updates = params_for(:group) |> with_location()
    updates = Map.put(updates, :id, group.id)

    %{
      "data" => %{
        "updateGroup" => %{
          "messages" => [],
          "result" => %{"description" => description, "id" => id, "name" => _name},
          "successful" => true
        }
      }
    } = update_group(conn, updates)

    assert id == Integer.to_string(group.id)
    assert description == updates.description
  end

  test "update a group - error", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    group = insert(:group) |> with_location()
    updates = params_for(:group) |> with_location()
    updates = Map.merge(updates, %{name: "", id: group.id})

    %{
      "data" => %{
        "updateGroup" => %{
          "successful" => successful,
          "messages" => [
            %{
              "field" => field,
              "message" => "can't be blank"
            }
          ],
          "result" => result
        }
      }
    } = update_group(conn, updates)

    refute successful
    assert field == "name"
    assert result == nil
  end

  # Delete A Group
  # ------------------------------------------------------------
  test "delete a group - success", %{conn: conn} do
    insert(:user)
    |> mock_sign_in

    group = insert(:group)
    delete_group(conn, group.id)

    assert Profiles.get_group(group.id) == nil
  end
end
