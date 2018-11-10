defmodule FerryWeb.LinkControllerTest do
  use FerryWeb.ConnCase

  alias Ferry.Links
  alias Ferry.Profiles

  # Link Controller Tests
  # ==============================================================================

  # Data & Helpers
  # ----------------------------------------------------------

  @create_attrs %{category: "News", label: "It's Going Down", url: "https://itsgoingdown.org/"}
  @update_attrs %{category: "News", label: "Are You Syrious?", url: "https://medium.com/@AreYouSyrious"}
  @invalid_attrs %{category: nil, label: nil, url: nil}

  def fixture(:group) do
    {:ok, group} = Profiles.create_group(%{name: "My Refugee Aid Group"})
    group
  end

  def fixture(:link) do
    group = fixture(:group)
    {:ok, link} = Links.create_link(group, @create_attrs)
    {group, link}
  end

  defp create_group(_) do
    group = fixture(:group)
    {:ok, group: group}
  end

  defp create_link(_) do
    {group, link} = fixture(:link)
    {:ok, group: group, link: link}
  end

  # Show
  # ----------------------------------------------------------

  describe "index" do
    setup [:create_group]

    # TODO: actually lists no links since none are created... test both cases
    test "lists all links", %{conn: conn, group: group} do
      conn = get conn, group_link_path(conn, :index, group)
      assert html_response(conn, 200) =~ "Listing Links"
    end

    test "shows 404 not found for non-existent groups", %{conn: conn} do
      assert_error_sent 404, fn ->
        get conn, group_link_path(conn, :index, 1312)
      end
    end
  end

  describe "show" do
    setup [:create_link]

    test "lists the specified link", %{conn: conn, group: group, link: link} do
      conn = get conn, group_link_path(conn, :show, group, link)
      assert html_response(conn, 200) =~ "Show Link"
    end

    test "shows 404 not found for non-existent groups", %{conn: conn, group: _, link: link} do
      assert_error_sent 404, fn ->
        get conn, group_link_path(conn, :show, 1312, link)
      end
    end

    test "shows 404 not found for non-existent links", %{conn: conn, group: group, link: _} do
      assert_error_sent 404, fn ->
        get conn, group_link_path(conn, :show, group, 1312)
      end
    end
  end

  # Create
  # ----------------------------------------------------------

  describe "new link" do
    setup [:create_group]

    test "renders form", %{conn: conn, group: group} do
      conn = get conn, group_link_path(conn, :new, group)
      assert html_response(conn, 200) =~ "New Link"
    end

    test "shows 404 not found for non-existent groups", %{conn: conn, group: _} do
      assert_error_sent 404, fn ->
        get conn, group_link_path(conn, :new, 1312)
      end
    end
  end

  describe "create link" do
    setup [:create_group]

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

    test "shows 404 not found for non-existent groups", %{conn: conn, group: _} do
      assert_error_sent 404, fn ->
        post conn, group_link_path(conn, :create, 1312), link: @create_attrs
      end
    end
  end

  # Update
  # ----------------------------------------------------------

  describe "edit link" do
    setup [:create_link]

    test "renders form for editing chosen link", %{conn: conn, group: group, link: link} do
      conn = get conn, group_link_path(conn, :edit, group, link)
      assert html_response(conn, 200) =~ "Edit Link"
    end

    test "shows 404 not found for non-existent groups", %{conn: conn, group: _, link: link} do
      assert_error_sent 404, fn ->
        get conn, group_link_path(conn, :edit, 1312, link)
      end
    end

    test "shows 404 not found for non-existent links", %{conn: conn, group: group, link: _} do
      assert_error_sent 404, fn ->
        get conn, group_link_path(conn, :edit, group, 1312)
      end
    end
  end

  describe "update link" do
    setup [:create_link]

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

    test "shows 404 not found for non-existent groups", %{conn: conn, group: _, link: link} do
      assert_error_sent 404, fn ->
        put conn, group_link_path(conn, :update, 1312, link), link: @update_attrs
      end
    end

    test "shows 404 not found for non-existent links", %{conn: conn, group: group, link: _} do
      assert_error_sent 404, fn ->
        put conn, group_link_path(conn, :update, group, 1312), link: @update_attrs
      end
    end
  end

  # Delete
  # ----------------------------------------------------------

  describe "delete link" do
    setup [:create_link]

    test "deletes chosen link", %{conn: conn, group: group, link: link} do
      conn = delete conn, group_link_path(conn, :delete, group, link)
      assert redirected_to(conn) == group_link_path(conn, :index, group)
      assert_error_sent 404, fn ->
        get conn, group_link_path(conn, :show, group, link)
      end
    end

    test "shows 404 not found for non-existent groups", %{conn: conn, group: _, link: link} do
      assert_error_sent 404, fn ->
        delete conn, group_link_path(conn, :delete, 1312, link)
      end
    end

    test "shows 404 not found for non-existent links", %{conn: conn, group: group, link: _} do
      assert_error_sent 404, fn ->
        delete conn, group_link_path(conn, :delete, group, 1312)
      end
    end
  end

end
