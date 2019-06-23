defmodule FerryWeb.UserControllerTest do
  use FerryWeb.ConnCase

  # User Controller Tests
  # ==============================================================================

  setup do
    group = insert(:group)

    conn = build_conn()
    {:ok, conn: conn, group: group}
  end

  # Errors
  # ----------------------------------------------------------

  describe "errors" do
    test "shows 404 not found for non-existent groups", %{conn: conn} do
      Enum.each(
        [
          # unauthenticated
          fn -> get conn, Routes.group_user_path(conn, :new, 1312) end,
          fn -> post conn, Routes.group_user_path(conn, :create, 1312), user: params_for(:user) end,

        ],
        fn request -> assert_error_sent 404, request end
      )
    end
  end

  # Create
  # ----------------------------------------------------------

  describe "new user" do
    test "renders form", %{conn: conn, group: group} do
      conn = get conn, Routes.group_user_path(conn, :new, group)
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "create user" do
    test "redirects to show when data is valid", %{conn: conn, group: group} do
      conn = post conn, Routes.group_user_path(conn, :create, group), user: params_for(:new_user)

      assert redirected_to(conn) == Routes.home_page_path(conn, :index)

      # TODO: assert the user was created???
      # conn = get conn, Routes.user_path(conn, :show, id)
      # assert html_response(conn, 200) =~ "Show User"
    end

    test "renders errors when data is invalid", %{conn: conn, group: group} do
      conn = post conn, Routes.group_user_path(conn, :create, group), user: params_for(:invalid_user)
      assert html_response(conn, 200) =~ "New User"
    end
  end

end
