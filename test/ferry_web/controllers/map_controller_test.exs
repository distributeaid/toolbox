defmodule FerryWeb.MapControllerTest do
  use FerryWeb.ConnCase

  # Map Controller Tests
  # ==============================================================================

  setup do
    group = insert(:group)
    user = insert(:user, group: group)
    addresses = [insert(:address, group: group), insert(:address, group: group)]

    conn = build_conn()
    conn = post conn, Routes.session_path(conn, :create, %{user: %{email: user.email, password: @password}})
    {:ok, conn: conn, group: group, user: user, addresses: addresses}
  end

  # Show
  # ----------------------------------------------------------

  describe "show" do
    test "shows the map page with all addresses", %{conn: conn, addresses: addresses} do
      conn = get conn, Routes.map_path(conn, :show)
      assert html_response(conn, 200) =~ Enum.at(addresses, 0).label
      assert html_response(conn, 200) =~ Enum.at(addresses, 1).label
    end
  end


end
