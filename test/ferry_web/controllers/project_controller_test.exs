defmodule FerryWeb.ProjectControllerTest do
  use FerryWeb.ConnCase

  # Project Controller Tests
  # ==============================================================================

  setup do
    group = insert(:group)
    user = insert(:user, group: group)
    project = insert(:project, group: group)

    conn = build_conn()
    conn = post conn, Routes.session_path(conn, :create, %{user: %{email: user.email, password: @password}})
    {:ok, conn: conn, group: group, user: user, project: project}
  end

  # Errors
  # ----------------------------------------------------------

  describe "errors" do
    test "shows 401 unauthorized for non-logged-in users", %{group: group, project: project} do
      Enum.each(
        [
          get(build_conn(), Routes.group_project_path(build_conn(), :new, group)),
          post(build_conn(), Routes.group_project_path(build_conn(), :create, group), project: params_for(:project)),
          get(build_conn(), Routes.group_project_path(build_conn(), :edit, group, project)),
          put(build_conn(), Routes.group_project_path(build_conn(), :update, group, project), group: params_for(:project)),
          delete(build_conn(), Routes.group_project_path(build_conn(), :delete, group, project))
        ],
        fn conn -> assert conn.status == 401 end
      )
    end

    # NOTE: This covers the case of authenticated 404 errors for these actions,
    #       since the user will be unauthenticated for the non-existant group.
    test "shows 403 unauthenticated for actions on unassociated links", %{conn: conn} do
      not_my_group = insert(:group)
      not_my_project = insert(:project, group: not_my_group)

      Enum.each(
        [
          # authenticated
          post(conn, Routes.group_project_path(conn, :create, not_my_group), project: params_for(:project)),
          get(conn, Routes.group_project_path(conn, :new, not_my_group)),
          get(conn, Routes.group_project_path(conn, :edit, not_my_group, not_my_project)),
          put(conn, Routes.group_project_path(conn, :update, not_my_group, not_my_project), project: params_for(:project)),
          delete(conn, Routes.group_project_path(conn, :delete, not_my_group, not_my_project))
        ],
        fn conn -> assert conn.status == 403 end
      )
    end

    test "shows 404 not found for non-existent groups", %{conn: conn, project: project} do
      Enum.each(
        [
          # unauthenticated
          fn -> get build_conn(), Routes.group_project_path(build_conn(), :index, 1312) end,
          fn -> get build_conn(), Routes.group_project_path(build_conn(), :show, 1312, project) end,

          # authenticated
          fn -> get conn, Routes.group_project_path(conn, :index, 1312) end,
          fn -> get conn, Routes.group_project_path(conn, :show, 1312, project) end,
        ],
        fn request -> assert_error_sent 404, request end
      )
    end

    test "shows 404 not found for non-existent projects", %{conn: conn, group: group} do
      Enum.each(
        [
          # unauthenticated
          fn -> get build_conn(), Routes.group_project_path(build_conn(), :show, group, 1312) end,

          # authenticated
          fn -> get conn, Routes.group_project_path(conn, :show, group, 1312) end,
          fn -> get conn, Routes.group_project_path(conn, :edit, group, 1312) end,
          fn -> put conn, Routes.group_project_path(conn, :update, group, 1312), project: params_for(:project) end,
          fn -> delete conn, Routes.group_project_path(conn, :delete, group, 1312) end

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
      conn = get conn, Routes.project_path(conn, :index)
      assert html_response(conn, 200) =~ "Projects"
    end

    # TODO: test for 0, 1, n projects
    # TODO: test logged in (conn) & logged out (build_conn())
    test "lists all projects for a group", %{conn: conn, group: group} do
      conn = get conn, Routes.group_project_path(conn, :index, group)
      assert html_response(conn, 200) =~ "Projects"
    end
  end

  describe "show" do
    # TODO: test logged in (conn) & logged out (build_conn())
    test "lists the specified group", %{conn: conn, group: group, project: project} do
      conn = get conn, Routes.group_project_path(conn, :show, group, project)
      assert html_response(conn, 200) =~ project.name
    end
  end

  # Create
  # ----------------------------------------------------------

  describe "new project" do
    test "renders form", %{conn: conn, group: group} do
      conn = get conn, Routes.group_project_path(conn, :new, group)
      assert html_response(conn, 200) =~ "New Project"
    end
  end

  describe "create project" do
    test "redirects to show when data is valid", %{conn: conn, group: group} do
      project_params = params_for(:project)
      conn = post conn, Routes.group_project_path(conn, :create, group), project: project_params

      assert redirected_to(conn) == Routes.group_path(conn, :show, group)

      conn = get conn, Routes.group_path(conn, :show, group)
      assert html_response(conn, 200) =~ project_params.name
    end

    test "renders errors when data is invalid", %{conn: conn, group: group} do
      conn = post conn, Routes.group_project_path(conn, :create, group), project: params_for(:invalid_project)
      assert html_response(conn, 200) =~ "New Project"
    end
  end

  # Update
  # ----------------------------------------------------------

  describe "edit project" do
    test "renders form for editing chosen project", %{conn: conn, group: group, project: project} do
      conn = get conn, Routes.group_project_path(conn, :edit, group, project)
      assert html_response(conn, 200) =~ "Edit Project"
    end
  end

  describe "update project" do
    test "redirects when data is valid", %{conn: conn, group: group, project: project} do
      project_params = params_for(:project)
      conn = put conn, Routes.group_project_path(conn, :update, group, project), project: project_params

      assert redirected_to(conn) == Routes.group_path(conn, :show, group)

      conn = get conn, Routes.group_path(conn, :show, group)
      assert html_response(conn, 200) =~ project_params.name
    end

    test "renders errors when data is invalid", %{conn: conn, group: group, project: project} do
      conn = put conn, Routes.group_project_path(conn, :update, group, project), project: params_for(:invalid_project)
      assert html_response(conn, 200) =~ "Edit Project"
    end
  end

  # Delete
  # ----------------------------------------------------------

  describe "delete project" do
    test "deletes chosen project", %{conn: conn, group: group, project: project} do
      conn = delete conn, Routes.group_project_path(conn, :delete, group, project)
      assert redirected_to(conn) == Routes.group_path(conn, :show, group)
      assert_error_sent 404, fn ->
        get conn, Routes.group_project_path(conn, :show, group, project)
      end
    end
  end

end
