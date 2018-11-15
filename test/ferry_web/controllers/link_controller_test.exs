defmodule FerryWeb.LinkControllerTest do
  use FerryWeb.ConnCase

  alias Ferry.Accounts
  alias Ferry.Links
  alias Ferry.Profiles

  # Link Controller Tests
  # ==============================================================================

  # Data, Helpers, & Setup
  # ----------------------------------------------------------

  @create_attrs %{category: "News", label: "It's Going Down", url: "https://itsgoingdown.org/"}
  @update_attrs %{category: "News", label: "Are You Syrious?", url: "https://medium.com/@AreYouSyrious"}
  @invalid_attrs %{category: nil, label: nil, url: nil}

  @user_attrs %{email: "john.brown@example.org", password: "¡ø`¡£`ºª¨˚ß∂∆ƒ ;dsajf"}

  def fixture(:group) do
    {:ok, group} = Profiles.create_group(%{name: "My Refugee Aid Group"})
    {group}
  end

  def fixture(:user) do
    {group} = fixture(:group)
    {:ok, user} = Accounts.create_user(group, @user_attrs)
    {group, user}
  end

  def fixture(:link, group) do
    {:ok, link} = Links.create_link(group, @create_attrs)
    {link}
  end

  setup do
    {group, user} = fixture(:user)
    {link} = fixture(:link, group)

    conn = build_conn()
    conn = post conn, session_path(conn, :create, @user_attrs)
    {:ok, conn: conn, group: group, user: user, link: link}
  end

  # Errors
  # ----------------------------------------------------------

  describe "errors" do
    test "shows 401 unauthorized for non-logged-in users", %{group: group, link: link} do
      Enum.each(
        [
          get(build_conn(), group_link_path(build_conn(), :new, group)),
          post(build_conn(), group_link_path(build_conn(), :create, group), link: @create_attrs),
          get(build_conn(), group_link_path(build_conn(), :edit, group, link)),
          put(build_conn(), group_link_path(build_conn(), :update, group, link), group: @update_attrs),
          delete(build_conn(), group_link_path(build_conn(), :delete, group, link))
        ],
        fn conn -> assert conn.status == 401 end
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
          fn -> post conn, group_link_path(conn, :create, 1312), link: @create_attrs end,
          fn -> get conn, group_link_path(conn, :new, 1312) end,
          fn -> get conn, group_link_path(conn, :edit, 1312, link) end,
          fn -> put conn, group_link_path(conn, :update, 1312, link), link: @update_attrs end,
          fn -> delete conn, group_link_path(conn, :delete, 1312, link) end
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
          fn -> put conn, group_link_path(conn, :update, group, 1312), link: @update_attrs end,
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
      assert html_response(conn, 200) =~ "Listing Links"
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
      conn = post conn, group_link_path(conn, :create, group), link: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == group_link_path(conn, :show, group, id)

      conn = get conn, group_link_path(conn, :show, group, id)
      assert html_response(conn, 200) =~ "Show Link"
    end

    test "renders errors when data is invalid", %{conn: conn, group: group} do
      conn = post conn, group_link_path(conn, :create, group), link: @invalid_attrs
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
      conn = put conn, group_link_path(conn, :update, group, link), link: @update_attrs
      assert redirected_to(conn) == group_link_path(conn, :show, group, link)

      conn = get conn, group_link_path(conn, :show, group, link)
      assert html_response(conn, 200) =~ @update_attrs.url
    end

    test "renders errors when data is invalid", %{conn: conn, group: group, link: link} do
      conn = put conn, group_link_path(conn, :update, group, link), link: @invalid_attrs
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
