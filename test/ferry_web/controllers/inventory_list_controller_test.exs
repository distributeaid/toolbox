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
    test "shows the inventory list page with all stock", %{conn: conn} do
      stock1 = insert(:stock, %{have: 11, need: 22})
      stock2 = insert(:stock, %{have: 0, need: 55})
      stock3 = insert(:stock, %{have: 44, need: 0})

      conn = get conn, Routes.inventory_list_path(conn, :show)
      assert html_response(conn, 200) =~ stock1.have |> Integer.to_string()
      assert html_response(conn, 200) =~ stock2.need |> Integer.to_string()
      assert html_response(conn, 200) =~ stock3.have |> Integer.to_string()
    end
  end


end
