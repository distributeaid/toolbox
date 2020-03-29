defmodule Ferry.GroupTest do
  use FerryWeb.ConnCase, async: true


  # List Groups
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


  # Get Groups
  # ------------------------------------------------------------
  test "get a groups - found", %{conn: conn} do
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

  test "get all groups - no group", %{conn: conn} do
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


end
