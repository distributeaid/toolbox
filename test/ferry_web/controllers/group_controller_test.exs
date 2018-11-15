defmodule FerryWeb.GroupControllerTest do
  use FerryWeb.ConnCase

  alias Ferry.Accounts
  alias Ferry.Profiles

  # Group Controller Test
  # ==============================================================================

  # Data, Helpers, & Setup
  # ----------------------------------------------------------

  @create_attrs %{name: "My Local Refugee Aid Group", description: "We help newcomers!"}
  @update_attrs %{name: "My International Refugee Aid Group", description: "We collect donations!"}
  @invalid_attrs %{name: nil}

  @user_attrs %{email: "john.brown@example.org", password: "¡ø`¡£`ºª¨˚ß∂∆ƒ ;dsajf"}

  def fixture(:group) do
    {:ok, group} = Profiles.create_group(@create_attrs)
    {group}
  end

  def fixture(:user) do
    {group} = fixture(:group)
    {:ok, user} = Accounts.create_user(group, @user_attrs)
    {group, user}
  end

  setup do
    {group, user} = fixture(:user)

    conn = build_conn()
    conn = post conn, session_path(conn, :create, @user_attrs)
    {:ok, conn: conn, group: group, user: user}
  end

  # Errors
  # ----------------------------------------------------------

  describe "errors" do
    test "shows 401 unauthorized for non-logged-in users", %{group: group} do
      Enum.each(
        [
          get(build_conn(), group_path(build_conn(), :edit, group)),
          put(build_conn(), group_path(build_conn(), :update, group), group: @update_attrs),
          delete(build_conn(), group_path(build_conn(), :delete, group))
        ],
        fn conn -> assert conn.status == 401 end
      )
    end

    test "shows 404 not found for non-existent groups", %{conn: conn} do
      Enum.each(
        [
          # unauthenticated
          fn -> get build_conn(), group_path(build_conn(), :show, 1312) end,

          # authenticated
          fn -> get conn, group_path(conn, :show, 1312) end,
          fn -> get conn, group_path(conn, :edit, 1312) end,
          fn -> put conn, group_path(conn, :update, 1312), group: @update_attrs end,
          fn -> delete conn, group_path(conn, :delete, 1312) end
        ],
        fn request -> assert_error_sent 404, request end
      )
    end
  end

  # Show
  # ----------------------------------------------------------

  describe "index" do
    # TODO: test for 0, 1, n groups
    # TODO: test logged in (conn) & logged out (build_conn())
    test "lists all groups", %{conn: conn} do
      conn = get conn, group_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Groups"
    end
  end

  describe "show" do
    # TODO: test logged in (conn) & logged out (build_conn())
    test "lists the specified group", %{conn: conn, group: group} do
      conn = get conn, group_path(conn, :show, group.id)
      assert html_response(conn, 200) =~ "Show Group"
    end
  end

  # Create
  # ----------------------------------------------------------
  # TODO: move these tests to the admin group controller tests when it's created.

  # describe "new group" do
  #   test "renders form", %{conn: conn} do
  #     conn = get conn, group_path(conn, :new)
  #     assert html_response(conn, 200) =~ "New Group"
  #   end
  #
  #   test "shows 401 unauthorized for non-logged-in users"
  # end

  # describe "create group" do
  #   test "redirects to show when data is valid", %{conn: conn} do
  #     conn = post conn, group_path(conn, :create), group: @create_attrs

  #     assert %{id: id} = redirected_params(conn)
  #     assert redirected_to(conn) == group_path(conn, :show, id)

  #     conn = get conn, group_path(conn, :show, id)
  #     assert html_response(conn, 200) =~ "Show Group"
  #   end

  #   test "renders errors when data is invalid", %{conn: conn} do
  #     conn = post conn, group_path(conn, :create), group: @invalid_attrs
  #     assert html_response(conn, 200) =~ "New Group"
  #   end
  #
  #   test "shows 401 unauthorized for non-logged-in users"
  # end

  # Update
  # ----------------------------------------------------------

  describe "edit group" do
    test "renders form for editing chosen group", %{conn: conn, group: group} do
      conn = get conn, group_path(conn, :edit, group)
      assert html_response(conn, 200) =~ "Edit Group"
    end
  end

  describe "update group" do
    test "redirects when data is valid", %{conn: conn, group: group} do
      conn = put conn, group_path(conn, :update, group), group: @update_attrs
      assert redirected_to(conn) == group_path(conn, :show, group)

      conn = get conn, group_path(conn, :show, group)
      assert html_response(conn, 200) =~ @update_attrs.description
    end

    test "renders errors when data is invalid", %{conn: conn, group: group} do
      conn = put conn, group_path(conn, :update, group), group: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Group"
    end
  end

  # Delete
  # ----------------------------------------------------------

  describe "delete group" do
    test "deletes chosen group", %{conn: conn, group: group} do
      conn = delete conn, group_path(conn, :delete, group)
      assert redirected_to(conn) == group_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, group_path(conn, :show, group)
      end
    end
  end

end
