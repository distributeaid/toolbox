defmodule FerryWeb.ShipmentOverviewControllerTest do
  use FerryWeb.ConnCase


  # Shipment Controller Tests
  # ==============================================================================

  setup do
    group = insert(:group)
    user = insert(:user, group: group)
    shipment = insert(:shipment)

    conn = build_conn()
    conn = post conn, Routes.session_path(conn, :create, %{user: %{email: user.email, password: @password}})
    {:ok, conn: conn, group: group, user: user, shipment: shipment}
  end

  # Errors
  # ----------------------------------------------------------
  # TODO


  # Show
  # ----------------------------------------------------------

  describe "index" do
    test "lists all shipments", %{conn: conn, shipment: shipment} do
      conn = get conn, Routes.shipment_overview_path(conn, :index)
      response = html_response(conn, 200)
      assert response =~ "Shipments"
      assert response =~ shipment.label
    end
  end

  describe "show" do
    test "lists the specified shipment", %{conn: conn, shipment: shipment} do
      conn = get conn, Routes.shipment_overview_path(conn, :show, shipment)
      assert html_response(conn, 200) =~ shipment.label
    end
  end

end