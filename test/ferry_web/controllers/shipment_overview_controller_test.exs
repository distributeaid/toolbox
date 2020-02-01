defmodule FerryWeb.ShipmentOverviewControllerTest do
  use FerryWeb.ConnCase


  # Shipment Controller Tests
  # ==============================================================================

  setup do
    group = insert(:group)
    user = insert(:user, group: group)
    shipment = insert(:shipment) |> with_role(group) |> with_route()

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
      assert response =~ shipment.target_date
    end
  end

  describe "show" do
    test "lists the specified shipment", %{conn: conn, shipment: shipment} do
      # my shipment
      conn = get conn, Routes.shipment_overview_path(conn, :show, shipment)
      assert html_response(conn, 200) =~ shipment.target_date

      # not my shipment
      other_shipment = insert(:shipment) |> with_role() |> with_route()
      conn = get conn, Routes.shipment_overview_path(conn, :show, other_shipment)
      assert html_response(conn, 200) =~ other_shipment.target_date
    end
  end

end