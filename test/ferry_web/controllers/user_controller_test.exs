defmodule FerryWeb.UserControllerTest do
  use FerryWeb.ConnCase

  alias Ferry.Accounts
  alias Ferry.Profiles

  # User Controller Tests
  # ==============================================================================
  
  # Data, Helpers, & Setup
  # ----------------------------------------------------------

  @create_attrs %{email: "red@example.org", password: "ø≈ƒ©ƒª•ªøƒπ∂ˆ¨©•ª¨∂©"}
  @update_attrs %{email: "black@example.org", password: "ªƒ••º©¨∂ºª¡™£¢∞§§¶ª–"}
  @invalid_attrs %{email: nil, password: nil}

  @user_attrs %{email: "john.brown@example.org", password: "¡ø`¡£`ºª¨˚ß∂∆ƒ ;dsajf"}

  def fixture(:group) do
    {:ok, group} = Profiles.create_group(%{name: "My Refugee Aid Group"})
    {group}
  end

  setup do
    {group} = fixture(:group)

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
          fn -> get conn, group_user_path(conn, :new, 1312) end,
          fn -> post conn, group_user_path(conn, :create, 1312), user: @create_attrs end,

        ],
        fn request -> assert_error_sent 404, request end
      )
    end
  end

  # Create
  # ----------------------------------------------------------

  describe "new user" do
    test "renders form", %{conn: conn, group: group} do
      conn = get conn, group_user_path(conn, :new, group)
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "create user" do
    test "redirects to show when data is valid", %{conn: conn, group: group} do
      conn = post conn, group_user_path(conn, :create, group), user: @create_attrs

      assert redirected_to(conn) == home_page_path(conn, :index)

      # TODO: assert the user was created???
      # conn = get conn, user_path(conn, :show, id)
      # assert html_response(conn, 200) =~ "Show User"
    end

    test "renders errors when data is invalid", %{conn: conn, group: group} do
      conn = post conn, group_user_path(conn, :create, group), user: @invalid_attrs
      assert html_response(conn, 200) =~ "New User"
    end
  end

end
