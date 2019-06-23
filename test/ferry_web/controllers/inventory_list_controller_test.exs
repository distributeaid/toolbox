defmodule FerryWeb.InventoryListControllerTest do
  use FerryWeb.ConnCase

  # Inventory Controller Tests
  # ==============================================================================

  setup do
    group = insert(:group)
    user = insert(:user, group: group)
    project = insert(:project, group: group)
    stock = insert(:stock, project: project)

    conn = build_conn()
    conn = post conn, Routes.session_path(conn, :create, %{user: %{email: user.email, password: @password}})
    {:ok, conn: conn, group: group, user: user, project: project, stock: stock}
  end

  # Show
  # ----------------------------------------------------------
  # TODO: test filters n labels?

  describe "show" do
    test "shows the available inventory list page with all available stock", %{conn: conn, stock: stock1} do
      stock2 = insert(:stock)
      stock3 = insert(:stock, %{have: 0, need: 50})

      conn = get conn, Routes.inventory_list_path(conn, :show)
      assert html_response(conn, 200) =~ stock1.item.name
      assert html_response(conn, 200) =~ stock2.item.name
      refute html_response(conn, 200) =~ stock3.item.name
    end

    test "shows the available inventory list page with all needed stock", %{conn: conn, stock: stock1} do
      stock2 = insert(:stock, %{have: 0, need: 50})
      stock3 = insert(:stock, %{have: 0, need: 50})

      conn = get conn, Routes.inventory_list_path(conn, :show, type: "needs")
      refute html_response(conn, 200) =~ stock1.item.name
      assert html_response(conn, 200) =~ stock2.item.name
      assert html_response(conn, 200) =~ stock3.item.name
    end
  end


end
