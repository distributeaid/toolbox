defmodule FerryWeb.ProjectControllerTest do
  use FerryWeb.ConnCase

  # Project Controller Tests
  # ==============================================================================

  setup do
    group = insert(:group)
    user = insert(:user, group: group)
    project = insert(:project, group: group)

    conn = build_conn()
    conn = post conn, session_path(conn, :create, %{email: user.email, password: @password})
    {:ok, conn: conn, group: group, user: user, project: project}
  end

  # Errors
  # ----------------------------------------------------------

  describe "errors" do
    test "shows 401 unauthorized for non-logged-in users", %{group: group, project: project} do
      Enum.each(
        [
          get(build_conn(), group_project_path(build_conn(), :new, group)),
          post(build_conn(), group_project_path(build_conn(), :create, group), project: params_for(:project)),
          get(build_conn(), group_project_path(build_conn(), :edit, group, project)),
          put(build_conn(), group_project_path(build_conn(), :update, group, project), group: params_for(:project)),
          delete(build_conn(), group_project_path(build_conn(), :delete, group, project))
        ],
        fn conn -> assert conn.status == 401 end
      )
    end

    test "shows 404 not found for non-existent groups", %{conn: conn, project: project} do
      Enum.each(
        [
          # unauthenticated
          fn -> get build_conn(), group_project_path(build_conn(), :index, 1312) end,
          fn -> get build_conn(), group_project_path(build_conn(), :show, 1312, project) end,

          # authenticated
          fn -> get conn, group_project_path(conn, :index, 1312) end,
          fn -> get conn, group_project_path(conn, :show, 1312, project) end,
          fn -> post conn, group_project_path(conn, :create, 1312), project: params_for(:project) end,
          fn -> get conn, group_project_path(conn, :new, 1312) end,
          fn -> get conn, group_project_path(conn, :edit, 1312, project) end,
          fn -> put conn, group_project_path(conn, :update, 1312, project), project: params_for(:project) end,
          fn -> delete conn, group_project_path(conn, :delete, 1312, project) end
        ],
        fn request -> assert_error_sent 404, request end
      )
    end

    test "shows 404 not found for non-existent projects", %{conn: conn, group: group} do
      Enum.each(
        [
          # unauthenticated
          fn -> get build_conn(), group_project_path(build_conn(), :show, group, 1312) end,

          # authenticated
          fn -> get conn, group_project_path(conn, :show, group, 1312) end,
          fn -> get conn, group_project_path(conn, :edit, group, 1312) end,
          fn -> put conn, group_project_path(conn, :update, group, 1312), project: params_for(:project) end,
          fn -> delete conn, group_project_path(conn, :delete, group, 1312) end

        ],
        fn request -> assert_error_sent 404, request end
      )
    end
  end

  # Show
  # ----------------------------------------------------------

  describe "index" do
    # TODO: test for 0, 1, n projects across 1, n groups
    # TODO: test logged in (conn) & logged out (build_conn())
    test "lists all projects", %{conn: conn} do
      conn = get conn, project_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Projects"
    end

    # TODO: test for 0, 1, n projects
    # TODO: test logged in (conn) & logged out (build_conn())
    test "lists all projects for a group", %{conn: conn, group: group} do
      conn = get conn, group_project_path(conn, :index, group)
      assert html_response(conn, 200) =~ "Listing Projects"
    end
  end

  describe "show" do
    # TODO: test logged in (conn) & logged out (build_conn())
    test "lists the specified group", %{conn: conn, group: group, project: project} do
      conn = get conn, group_project_path(conn, :show, group, project)
      assert html_response(conn, 200) =~ "Show Project"
    end
  end

  # Create
  # ----------------------------------------------------------

  describe "new project" do
    test "renders form", %{conn: conn, group: group} do
      conn = get conn, group_project_path(conn, :new, group)
      assert html_response(conn, 200) =~ "New Project"
    end
  end

  describe "create project" do
    test "redirects to show when data is valid", %{conn: conn, group: group} do
      conn = post conn, group_project_path(conn, :create, group), project: %{name: "Another Project"}

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == group_project_path(conn, :show, group, id)

      conn = get conn, group_project_path(conn, :show, group, id)
      assert html_response(conn, 200) =~ "Show Project"
    end

    test "renders errors when data is invalid", %{conn: conn, group: group} do
      conn = post conn, group_project_path(conn, :create, group), project: params_for(:invalid_project)
      assert html_response(conn, 200) =~ "New Project"
    end
  end

  # Update
  # ----------------------------------------------------------

  describe "edit project" do
    test "renders form for editing chosen project", %{conn: conn, group: group, project: project} do
      conn = get conn, group_project_path(conn, :edit, group, project)
      assert html_response(conn, 200) =~ "Edit Project"
    end
  end

  describe "update project" do
    test "redirects when data is valid", %{conn: conn, group: group, project: project} do
      conn = put conn, group_project_path(conn, :update, group, project), project: params_for(:project)
      assert redirected_to(conn) == group_project_path(conn, :show, group, project)

      conn = get conn, group_project_path(conn, :show, group, project)
      assert html_response(conn, 200) =~ params_for(:project).description
    end

    test "renders errors when data is invalid", %{conn: conn, group: group, project: project} do
      conn = put conn, group_project_path(conn, :update, group, project), project: params_for(:invalid_project)
      assert html_response(conn, 200) =~ "Edit Project"
    end
  end

  # Delete
  # ----------------------------------------------------------

  describe "delete project" do
    test "deletes chosen project", %{conn: conn, group: group, project: project} do
      conn = delete conn, group_project_path(conn, :delete, group, project)
      assert redirected_to(conn) == group_project_path(conn, :index, group)
      assert_error_sent 404, fn ->
        get conn, group_project_path(conn, :show, group, project)
      end
    end
  end

end
