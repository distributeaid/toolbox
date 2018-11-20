defmodule FerryWeb.LinkControllerTest do
  use FerryWeb.ConnCase

  # Link Controller Tests
  # ==============================================================================

  setup do
    group = insert(:group)
    user = insert(:user, group: group)
    link = insert(:link, group: group)

    conn = build_conn()
    conn = post conn, session_path(conn, :create, %{user: %{email: user.email, password: @password}})
    {:ok, conn: conn, group: group, user: user, link: link}
  end

  # Errors
  # ----------------------------------------------------------

  describe "errors" do
    test "shows 401 unauthorized for non-logged-in users", %{group: group, link: link} do
      Enum.each(
        [
          get(build_conn(), group_link_path(build_conn(), :new, group)),
          post(build_conn(), group_link_path(build_conn(), :create, group), link: params_for(:link)),
          get(build_conn(), group_link_path(build_conn(), :edit, group, link)),
          put(build_conn(), group_link_path(build_conn(), :update, group, link), group: params_for(:link)),
          delete(build_conn(), group_link_path(build_conn(), :delete, group, link))
        ],
        fn conn -> assert conn.status == 401 end
      )
    end

    # NOTE: This covers the case of authenticated 404 errors for these actions,
    #       since the user will be unauthenticated for the non-existant group.
    test "shows 403 unauthenticated for actions on unassociated links", %{conn: conn} do
      not_my_group = insert(:group)
      not_my_link = insert(:link, group: not_my_group)

      Enum.each(
        [
          # authenticated
          post(conn, group_link_path(conn, :create, not_my_group), link: params_for(:link)),
          get(conn, group_link_path(conn, :new, not_my_group)),
          get(conn, group_link_path(conn, :edit, not_my_group, not_my_link)),
          put(conn, group_link_path(conn, :update, not_my_group, not_my_link), link: params_for(:link)),
          delete(conn, group_link_path(conn, :delete, not_my_group, not_my_link))
        ],
        fn conn -> assert conn.status == 403 end
      )
    end

    test "shows 404 not found for non-existent groups", %{conn: conn, link: link} do
      Enum.each(
        [
          # unauthenticated
          fn -> get build_conn(), group_link_path(build_conn(), :index, 1312) end,
          fn -> get build_conn(), group_link_path(build_conn(), :show, 1312, link) end,

          # authenticated
          fn -> get conn, group_link_path(conn, :index, 1312) end,
          fn -> get conn, group_link_path(conn, :show, 1312, link) end,
        ],
        fn request -> assert_error_sent 404, request end
      )
    end

    test "shows 404 not found for non-existent links", %{conn: conn, group: group} do
      Enum.each(
        [
          # unauthenticated
          fn -> get build_conn(), group_link_path(build_conn(), :show, group, 1312) end,

          # authenticated
          fn -> get conn, group_link_path(conn, :show, group, 1312) end,
          fn -> get conn, group_link_path(conn, :edit, group, 1312) end,
          fn -> put conn, group_link_path(conn, :update, group, 1312), link: params_for(:link) end,
          fn -> delete conn, group_link_path(conn, :delete, group, 1312) end

        ],
        fn request -> assert_error_sent 404, request end
      )
    end
  end

  # Show
  # ----------------------------------------------------------

  describe "index" do
    # TODO: actually lists no links since none are created... test both cases
    test "lists all links", %{conn: conn, group: group} do
      conn = get conn, group_link_path(conn, :index, group)
      assert html_response(conn, 200) =~ "Links"
    end
  end

  describe "show" do
    test "lists the specified link", %{conn: conn, group: group, link: link} do
      conn = get conn, group_link_path(conn, :show, group, link)
      assert html_response(conn, 200) =~ "Show Link"
    end
  end

  # Create
  # ----------------------------------------------------------

  describe "new link" do
    test "renders form", %{conn: conn, group: group} do
      conn = get conn, group_link_path(conn, :new, group)
      assert html_response(conn, 200) =~ "New Link"
    end
  end

  describe "create link" do
    test "redirects to show when data is valid", %{conn: conn, group: group} do
      link_params = params_for(:link)
      conn = post conn, group_link_path(conn, :create, group), link: link_params

      assert redirected_to(conn) == group_link_path(conn, :index, group)

      conn = get conn, group_link_path(conn, :index, group)
      assert html_response(conn, 200) =~ link_params.url
    end

    test "renders errors when data is invalid", %{conn: conn, group: group} do
      conn = post conn, group_link_path(conn, :create, group), link: params_for(:invalid_link)
      assert html_response(conn, 200) =~ "New Link"
    end
  end

  # Update
  # ----------------------------------------------------------

  describe "edit link" do
    test "renders form for editing chosen link", %{conn: conn, group: group, link: link} do
      conn = get conn, group_link_path(conn, :edit, group, link)
      assert html_response(conn, 200) =~ "Edit Link"
    end
  end

  describe "update link" do
    test "redirects when data is valid", %{conn: conn, group: group, link: link} do
      link_params = params_for(:link)
      conn = put conn, group_link_path(conn, :update, group, link), link: link_params

      assert redirected_to(conn) == group_link_path(conn, :index, group)

      conn = get conn, group_link_path(conn, :index, group)
      assert html_response(conn, 200) =~ link_params.url
    end

    test "renders errors when data is invalid", %{conn: conn, group: group, link: link} do
      conn = put conn, group_link_path(conn, :update, group, link), link: params_for(:invalid_link)
      assert html_response(conn, 200) =~ "Edit Link"
    end
  end

  # Delete
  # ----------------------------------------------------------

  describe "delete link" do
    test "deletes chosen link", %{conn: conn, group: group, link: link} do
      conn = delete conn, group_link_path(conn, :delete, group, link)
      assert redirected_to(conn) == group_link_path(conn, :index, group)
      assert_error_sent 404, fn ->
        get conn, group_link_path(conn, :show, group, link)
      end
    end
  end

end
