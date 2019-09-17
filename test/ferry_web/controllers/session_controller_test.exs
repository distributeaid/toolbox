defmodule FerryWeb.SessionControllerTest do
  use FerryWeb.ConnCase

  # Session Controller Test
  # ==============================================================================

  setup do
    group = insert(:group)
    user = insert(:user, group: group)

    conn = build_conn()
    conn = post conn, Routes.session_path(conn, :create, %{user: %{email: user.email, password: @password}})
    {:ok, conn: conn, group: group, user: user}
  end

  # Errors
  # ----------------------------------------------------------
  # No real routing errors to test- the session routes are only public, and are
  # a singleton so there are no logged in checks or 404 pages to show.
  #
  # Maybe if you try to delete a session without being logged in?  But that's
  # unlikely to happen from just browsing.

  # Create
  # ------------------------------------------------------------
  describe "new session" do
    test "renders form when logged out", %{} do
      conn = build_conn()
      conn = get conn, Routes.session_path(conn, :new)
      assert html_response(conn, 200) =~ "Login"
    end

    test "redirects to dashboard when logged in", %{conn: conn} do
      conn = get conn, Routes.session_path(conn, :new)
      assert redirected_to(conn) == Routes.home_page_path(conn, :index)
    end
  end

  describe "create session" do
    test "redirects to the dashboard when data is valid", %{user: user} do
      conn = build_conn()
      user_params = %{user: %{email: user.email, password: @password}}
      conn = post conn, Routes.session_path(conn, :create, user_params)

      assert redirected_to(conn) == Routes.home_page_path(conn, :index)
    end

    test "renders errors when data is invalid", %{} do
      conn = build_conn()
      user_params = %{user: %{email: "not an email", password: "too short"}}
      conn = post conn, Routes.session_path(conn, :create, user_params)
      assert html_response(conn, 200) =~ "Login"
    end
  end

  # Delete
  # ------------------------------------------------------------
  describe "delete session" do
    test "deletes chosen session", %{conn: conn} do
      conn = delete conn, Routes.session_path(conn, :delete)
      assert redirected_to(conn) == Routes.home_page_path(conn, :index)

      conn = get conn, Routes.session_path(conn, :new)
      assert html_response(conn, 200) =~ "Login"
    end
  end

end