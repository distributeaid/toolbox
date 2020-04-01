defmodule Ferry.GroupTest do
  use FerryWeb.ConnCase, async: true

  alias Ferry.Profiles


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
    groups = insert_list(3, :group)

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
        description
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
      "description" => group.description
    }

    query = """
    {
      groups {
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

    assert res == %{"data" => %{"groups" => [group_params]}}
  end

  test "get all groups - many", %{conn: conn} do
    groups = insert_pair(:group)
    groups_params = Enum.map(groups, fn group ->
      %{
        "id" => Integer.to_string(group.id),
        "name" => group.name,
        "description" => group.description
      }
    end)    

    query = """
    {
      groups {
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

    assert res == %{
      "data" => %{"group" => nil},
      "errors" => [%{
        "id" => "161",
        "locations" => [%{"column" => 0, "line" => 2}],
        "message" => "Group not found.",
        "path" => ["group"]
      }]
    }
  end

  # Mutation - Create A Group
  # ------------------------------------------------------------
  test "create a group - success", %{conn: conn} do
    group_attrs = params_for(:group)

    mutation = """
      mutation {
        createGroup(name: "#{group_attrs.name}", description: "#{group_attrs.description}") {
          id,
          name,
          description
        }
      }
    """

    res =
      conn
      |> post("/api", %{query: mutation})
      |> json_response(200)

    %{"data" => %{"createGroup" => %{"id" =>  id, "name" => name, "description" => description}}} = res
    assert id
    assert name == group_attrs.name
    assert description == group_attrs.description
  end

  # Mutation - Update A Group
  # ------------------------------------------------------------
  test "update a group - success", %{conn: conn} do
    group = insert(:group)
    updates = params_for(:group)

    mutation = """
      mutation {
        updateGroup(id: #{group.id}, description: "#{group.description}") {
          id,
          name,
          description
        }
      }
    """

    res =
      conn
      |> post("/api", %{query: mutation})
      |> json_response(200)

    %{"data" => %{"updateGroup" => %{"id" => id, "name" => name, "description" => description}}} = res
    assert id == Integer.to_string(group.id)
    assert name == group.name
    assert description == updates.description
  end

  # Delete A Group
  # ------------------------------------------------------------
  test "delete a group - success", %{conn: conn} do
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
