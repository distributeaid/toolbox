defmodule FerryWeb.ProjectControllerTest do
  use FerryWeb.ConnCase

  alias Ferry.Profiles

  # Project Controller Tests
  # ==============================================================================
  
  # Data & Helpers
  # ----------------------------------------------------------

  @create_attrs %{description: "some description", name: "some name"}
  @update_attrs %{description: "some updated description", name: "some updated name"}
  @invalid_attrs %{description: nil, name: nil}

  def fixture(:group) do
    {:ok, group} = Profiles.create_group(%{name: "My Refugee Aid Group"})
    group
  end

  def fixture(:project) do
    group = fixture(:group)
    {:ok, project} = Profiles.create_project(group, @create_attrs)
    {group, project}
  end

  defp create_group(_) do
    group = fixture(:group)
    {:ok, group: group}
  end

  defp create_project(_) do
    {group, project} = fixture(:project)
    {:ok, group: group, project: project}
  end

  # Show
  # ----------------------------------------------------------

  describe "index" do
    setup [:create_group]

    # TODO: actually lists no projects since none are created... test both cases
    test "lists all projects", %{conn: conn} do
      conn = get conn, project_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Projects"
    end

    # TODO: actually lists no projects since none are created... test both cases
    test "lists all projects for a group", %{conn: conn, group: group} do
      conn = get conn, group_project_path(conn, :index, group)
      assert html_response(conn, 200) =~ "Listing Projects"
    end

    test "shows 404 not found for non-existent groups", %{conn: conn} do
      assert_error_sent 404, fn ->
        get conn, group_project_path(conn, :index, 1312)
      end
    end
  end

  describe "show" do
    setup [:create_project]

    test "lists the specified group", %{conn: conn, group: group, project: project} do
      conn = get conn, group_project_path(conn, :show, group.id, project.id)
      assert html_response(conn, 200) =~ "Show Project"
    end

    test "shows 404 not found for non-existent groups", %{conn: conn, group: _, project: project} do
      assert_error_sent 404, fn ->
        get conn, group_project_path(conn, :show, 1312, project.id)
      end
    end

    test "shows 404 not found for non-existent projects", %{conn: conn, group: group, project: _} do
      assert_error_sent 404, fn ->
        get conn, group_project_path(conn, :show, group.id, 1312)
      end
    end
  end

  # Create
  # ----------------------------------------------------------

  describe "new project" do
    setup [:create_group]

    test "renders form", %{conn: conn, group: group} do
      conn = get conn, group_project_path(conn, :new, group)
      assert html_response(conn, 200) =~ "New Project"
    end

    test "shows 404 not found for non-existent groups", %{conn: conn, group: _} do
      assert_error_sent 404, fn ->
        get conn, group_project_path(conn, :index, 1312)
      end
    end
  end

  describe "create project" do
    setup [:create_group]

    test "redirects to show when data is valid", %{conn: conn, group: group} do
      conn = post conn, group_project_path(conn, :create, group), project: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == group_project_path(conn, :show, group, id)

      conn = get conn, group_project_path(conn, :show, group, id)
      assert html_response(conn, 200) =~ "Show Project"
    end

    test "renders errors when data is invalid", %{conn: conn, group: group} do
      conn = post conn, group_project_path(conn, :create, group), project: @invalid_attrs
      assert html_response(conn, 200) =~ "New Project"
    end

    test "shows 404 not found for non-existent groups", %{conn: conn, group: _} do
      assert_error_sent 404, fn ->
        get conn, group_project_path(conn, :index, 1312)
      end
    end
  end

  # Update
  # ----------------------------------------------------------

  describe "edit project" do
    setup [:create_project]

    test "renders form for editing chosen project", %{conn: conn, group: group, project: project} do
      conn = get conn, group_project_path(conn, :edit, group, project)
      assert html_response(conn, 200) =~ "Edit Project"
    end

    test "shows 404 not found for non-existent groups", %{conn: conn, group: _, project: project} do
      assert_error_sent 404, fn ->
        get conn, group_project_path(conn, :show, 1312, project.id)
      end
    end

    test "shows 404 not found for non-existent projects", %{conn: conn, group: group, project: _} do
      assert_error_sent 404, fn ->
        get conn, group_project_path(conn, :show, group.id, 1312)
      end
    end
  end

  describe "update project" do
    setup [:create_project]

    test "redirects when data is valid", %{conn: conn, group: group, project: project} do
      conn = put conn, group_project_path(conn, :update, group, project), project: @update_attrs
      assert redirected_to(conn) == group_project_path(conn, :show, group, project)

      conn = get conn, group_project_path(conn, :show, group, project)
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, group: group, project: project} do
      conn = put conn, group_project_path(conn, :update, group, project), project: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Project"
    end

    test "shows 404 not found for non-existent groups", %{conn: conn, group: _, project: project} do
      assert_error_sent 404, fn ->
        get conn, group_project_path(conn, :show, 1312, project.id)
      end
    end

    test "shows 404 not found for non-existent projects", %{conn: conn, group: group, project: _} do
      assert_error_sent 404, fn ->
        get conn, group_project_path(conn, :show, group.id, 1312)
      end
    end
  end

  # Delete
  # ----------------------------------------------------------

  describe "delete project" do
    setup [:create_project]

    test "deletes chosen project", %{conn: conn, group: group, project: project} do
      conn = delete conn, group_project_path(conn, :delete, group, project)
      assert redirected_to(conn) == group_project_path(conn, :index, group)
      assert_error_sent 404, fn ->
        get conn, group_project_path(conn, :show, group, project)
      end
    end

    test "shows 404 not found for non-existent groups", %{conn: conn, group: _, project: project} do
      assert_error_sent 404, fn ->
        get conn, group_project_path(conn, :show, 1312, project.id)
      end
    end

    test "shows 404 not found for non-existent projects", %{conn: conn, group: group, project: _} do
      assert_error_sent 404, fn ->
        get conn, group_project_path(conn, :show, group.id, 1312)
      end
    end
  end

end
