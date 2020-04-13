defmodule Ferry.GroupTest do
  use FerryWeb.ConnCase, async: true

  alias Ferry.Profiles

  import Mox

  # TODO: extract me to a test helper
  def sign_in_user do
    Ferry.Mocks.AwsClient
    |> expect(:request, fn _args ->
      {:ok, %{"Username" => "test_user"}}
    end)
  end

  # GROUPS
  # ================================================================================

  # Query - Count Groups
  # ------------------------------------------------------------

  test "count groups - none", %{conn: conn} do
    query = """
    {
      countGroups
    }
    """

    res =
      conn
      |> post("/api", %{query: query})
      |> json_response(200)

    %{"data" => %{"countGroups" => count}} = res
    assert count == 0
  end

  test "count groups - many", %{conn: conn} do
    insert_list(3, :group)

    query = """
    {
      countGroups
    }
    """

    res =
      conn
      |> post("/api", %{query: query})
      |> json_response(200)

    %{"data" => %{"countGroups" => count}} = res
    assert count == 3
  end

  # Query - Get All Groups
  # ------------------------------------------------------------
  test "get all groups - none", %{conn: conn} do
    query = """
    {
      groups {
        id,
        name,
        description,
        location {
          province,
          country_code,
          postal_code
        }
      }
    }
    """

    res =
      conn
      |> post("/api", %{query: query})
      |> json_response(200)

    assert res == %{"data" => %{"groups" => []}}
  end

  test "get all groups - one", %{conn: conn} do
    group = insert(:group)

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

    query = """
    {
      groups {
        id,
        name,
        description,
        location {
          province,
          country_code,
          postal_code
        }
      }
    }
    """

    res =
      conn
      |> post("/api", %{query: query})
      |> json_response(200)

    assert res == %{"data" => %{"groups" => [group_params]}}
  end

  test "get all groups - many", %{conn: conn} do
    groups = insert_pair(:group)

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

    query = """
    {
      groups {
        id,
        name,
        description,
        location {
          province,
          country_code,
          postal_code
        }
      }
    }
    """

    res =
      conn
      |> post("/api", %{query: query})
      |> json_response(200)

    assert res == %{"data" => %{"groups" => groups_params}}
  end

  # Query - Get A Group
  # ------------------------------------------------------------
  test "get a group - found", %{conn: conn} do
    group = insert(:group)

    group_params = %{
      "id" => Integer.to_string(group.id),
      "name" => group.name,
      "description" => group.description
    }

    query = """
    {
      group(id: #{group.id}) {
        id,
        name,
        description
      }
    }
    """

    res =
      conn
      |> post("/api", %{query: query})
      |> json_response(200)

    assert res == %{"data" => %{"group" => group_params}}
  end

  test "get a group - no group", %{conn: conn} do
    query = """
    {
      group(id: 161) {
        id,
        name,
        description
      }
    }
    """

    res =
      conn
      |> post("/api", %{query: query})
      |> json_response(200)

    assert(
      res == %{
        "data" => %{"group" => nil},
        "errors" => [
          %{
            "id" => "161",
            "locations" => [%{"column" => 0, "line" => 2}],
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
    sign_in_user()

    group_attrs = params_with_assocs(:group)

    mutation = """
      mutation {
        createGroup(
          groupInput: {
            name: "#{group_attrs.name}",
            slug: "#{group_attrs.slug}",

            description: "#{group_attrs.description}",
            slackChannelName: "#{group_attrs.slack_channel_name}",

            requestForm: "#{group_attrs.request_form}",
            requestFormResults: "#{group_attrs.request_form_results}",
            volunteerForm: "#{group_attrs.volunteer_form}",
            volunteerFormResults: "#{group_attrs.volunteer_form_results}",
            donationForm: "#{group_attrs.donation_form}",
            donationFormResults: "#{group_attrs.donation_form_results}",

            location: {
              province: "#{group_attrs.location.province}",
              country_code: "#{group_attrs.location.country_code}",
              postal_code: "#{group_attrs.location.postal_code}",
            }
          }
        ) {
          successful
          messages {
            field
            message
          }
          result {
            id,
            name,
            type,
            slug,
            slackChannelName,
            location {
              province,
              country_code,
              postal_code
            }
          }
        }
      }
    """

    res =
      conn
      |> post("/api", %{query: mutation})
      |> json_response(200)

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
    } = res

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
    sign_in_user()

    group_attrs = params_for(:invalid_group)

    mutation = """
      mutation {
        createGroup(
          groupInput: {
            name: "#{group_attrs.name}"
          }
        ) {
          successful
          messages {
            field
            message
          }
          result {
            id
          }
        }
      }
    """

    res =
      conn
      |> post("/api", %{query: mutation})
      |> json_response(200)

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
    } = res

    refute successful
    assert field == "name"
    assert result == nil
  end

  # Mutation - Update A Group
  # ------------------------------------------------------------
  test "update a group - success", %{conn: conn} do
    sign_in_user()

    group = insert(:group)
    updates = params_with_assocs(:group)

    mutation = """
      mutation {
        updateGroup(
          id: #{group.id},
          groupInput: {
            name: "#{updates.name}",
            slug: "#{updates.slug}",
            description: "#{updates.description}",
            slackChannelName: "#{updates.slack_channel_name}",
            requestForm: "#{updates.request_form}",
            requestFormResults: "#{updates.request_form_results}",
            volunteerForm: "#{updates.volunteer_form}",
            volunteerFormResults: "#{updates.volunteer_form_results}",
            donationForm: "#{updates.donation_form}",
            donationFormResults: "#{updates.donation_form_results}"

            location: {
              province: "#{updates.location.province}",
              country_code: "#{updates.location.country_code}",
              postal_code: "#{updates.location.postal_code}",
            }
          }
        ) {
          successful
          messages {
            field
            message
          }
          result {
            id
            name
            description
          }
        }
      }
    """

    res =
      conn
      |> post("/api", %{query: mutation})
      |> json_response(200)

    %{"data" => %{"updateGroup" => %{"messages" => [], "result" => %{"description" => description, "id" => id, "name" => _name}, "successful" => true}}} = res

    assert id == Integer.to_string(group.id)
    assert description == updates.description
  end

  test "update a group - error", %{conn: conn} do
    sign_in_user()

    group = insert(:group)
    updates = params_for(:invalid_group)

    mutation = """
      mutation {
        updateGroup(
          id: #{group.id},
          groupInput: {
            name: "#{updates.name}",
            description: "#{updates.description}",
            slackChannelName: "#{updates.slack_channel_name}",
            requestForm: "#{updates.request_form}",
            requestFormResults: "#{updates.request_form_results}",
            volunteerForm: "#{updates.volunteer_form}",
            volunteerFormResults: "#{updates.volunteer_form_results}",
            donationForm: "#{updates.donation_form}",
            donationFormResults: "#{updates.donation_form_results}"
          }
        ) {
          successful
          messages {
            field
            message
          }
          result {
            id
            name
            description
          }
        }
      }
    """

    res =
      conn
      |> post("/api", %{query: mutation})
      |> json_response(200)

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
    } = res

    refute successful
    assert field == "name"
    assert result == nil
  end

  # Delete A Group
  # ------------------------------------------------------------
  test "delete a group - success", %{conn: conn} do
    sign_in_user()

    group = insert(:group)

    mutation = """
      mutation {
        deleteGroup(id: #{group.id}) {
          id
        }
      }
    """

    _res =
      conn
      |> post("/api", %{query: mutation})
      |> json_response(200)

    assert Profiles.get_group(group.id) == nil
  end
end
