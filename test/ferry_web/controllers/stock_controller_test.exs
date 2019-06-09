defmodule FerryWeb.StockControllerTest do
  use FerryWeb.ConnCase


  # Stock Controller Tests
  # ================================================================================

  setup do
    group = insert(:group)
    user = insert(:user, group: group)
    project = insert(:project, group: group)
    stock = insert(:stock, project: project)

    conn = build_conn()
    conn = post conn, session_path(conn, :create, %{user: %{email: user.email, password: @password}})
    {:ok, conn: conn, group: group, user: user, project: project, stock: stock}
  end

  # Errors
  # ------------------------------------------------------------
  
  # TODO

  # Show
  # ------------------------------------------------------------
  
  describe "index" do
    # TODO: test for 0, 1, n projects across 1, n groups
    # TODO: test logged in (conn) & logged out (build_conn())
    test "lists all stocks for a group", %{conn: conn, group: group} do
      conn = get conn, group_stock_path(conn, :index, group)
      assert html_response(conn, 200) =~ "Inventory Manager"
    end
  end

  # Create
  # ------------------------------------------------------------

  describe "new stock" do
    test "renders form", %{conn: conn, group: group} do
      conn = get conn, group_stock_path(conn, :new, group)
      assert html_response(conn, 200) =~ "Add An Item"
    end
  end

  describe "create stock" do
    test "redirects to index when data is valid", %{conn: conn, group: group, project: project} do
      attrs = build(:stock_attrs, %{project: project})
      conn = post conn, group_stock_path(conn, :create, group), stock: attrs

      assert %{group_id: id} = redirected_params(conn)
      assert redirected_to(conn) == group_stock_path(conn, :index, group)

      conn = get conn, group_stock_path(conn, :index, group)
      assert html_response(conn, 200) =~ Integer.to_string(attrs["have"])
    end

    test "renders errors when data is invalid", %{conn: conn, group: group, project: project} do
      attrs = build(:stock_attrs, %{project: project})
      invalid_attrs = Map.merge(attrs, string_params_for(:invalid_short_stock))
      conn = post conn, group_stock_path(conn, :create, group), stock: invalid_attrs
      assert html_response(conn, 200) =~ "Add An Item"
    end
  end

  # Update
  # ------------------------------------------------------------

  describe "edit stock" do
    test "renders form for editing chosen stock", %{conn: conn, group: group, stock: stock} do
      conn = get conn, group_stock_path(conn, :edit, group, stock)
      assert html_response(conn, 200) =~ "Edit An Item"
    end
  end

  describe "update stock" do
    test "redirects when data is valid", %{conn: conn, group: group, project: project, stock: stock} do
      attrs = build(:stock_attrs, %{project: project})
      conn = put conn, group_stock_path(conn, :update, group, stock), stock: attrs
      assert redirected_to(conn) == group_stock_path(conn, :index, group)

      conn = get conn, group_stock_path(conn, :show, group, stock)
      assert html_response(conn, 200) =~ Integer.to_string(attrs["have"])
    end

    test "renders errors when data is invalid", %{conn: conn, group: group, project: project, stock: stock} do
      attrs = build(:stock_attrs, %{project: project})
      invalid_attrs = Map.merge(attrs, string_params_for(:invalid_short_stock))
      conn = put conn, group_stock_path(conn, :update, group, stock), stock: invalid_attrs
      assert html_response(conn, 200) =~ "Edit An Item"
    end
  end

  # Delete
  # ------------------------------------------------------------

  describe "delete stock" do
    test "deletes chosen stock", %{conn: conn, group: group, stock: stock} do
      conn = delete conn, group_stock_path(conn, :delete, group, stock)
      assert redirected_to(conn) == group_stock_path(conn, :index, group)
      assert_error_sent 404, fn ->
        get conn, group_stock_path(conn, :show, group, stock)
      end
    end
  end
end
