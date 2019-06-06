defmodule FerryWeb.InventoryControllerTest do
  use FerryWeb.ConnCase

  # Inventory Controller Tests
  # ==============================================================================

  setup do
    group = insert(:group)
    user = insert(:user, group: group)
    project = insert(:project, group: group)
    stock = insert(:stock, project: project)

    conn = build_conn()
    conn = post conn, session_path(conn, :create, %{user: %{email: user.email, password: @password}})
    {:ok, conn: conn, group: group, user: user, project: project, stock: stock}
  end

  # Show
  # ----------------------------------------------------------
  # TODO: test filters n labels?

  describe "show" do
    test "shows the inventory list page with all stock", %{conn: conn, stock: stock1} do
      stock2 = insert(:stock)
      stock3 = insert(:stock)

      conn = get conn, inventory_path(conn, :show)
      assert html_response(conn, 200) =~ Integer.to_string stock1.count
      assert html_response(conn, 200) =~ Integer.to_string stock2.count
      assert html_response(conn, 200) =~ Integer.to_string stock3.count
    end
  end


end
