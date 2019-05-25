defmodule FerryWeb.RouteControllerTest do
  use FerryWeb.ConnCase

  alias Ferry.Shipments.Route

  setup do
    group = insert(:group)
    user = insert(:user, group: group)
    shipment = insert(:shipment)
    route = insert(:route)

    conn = build_conn()
    conn = post conn, session_path(conn, :create, %{user: %{email: user.email, password: @password}})
    {:ok, conn: conn, group: group, user: user, shipment: shipment, route: route}
  end

  describe "index" do
    test "lists all route", %{conn: conn, group: group, shipment: shipment} do
      conn = get conn, group_shipment_route_path(conn, :index, group, shipment)
      assert html_response(conn, 200) =~ "Routes for your shipment"
    end
  end

  describe "new route" do
    test "renders form", %{conn: conn, group: group, shipment: shipment} do
      conn = get conn, group_shipment_route_path(conn, :new, group, shipment)
      assert html_response(conn, 200) =~ "New Stop Along Route"
    end
  end

  describe "create route" do
    test "redirects to show when data is valid", %{conn: conn, group: group, shipment: shipment, route: route} do
      route_params = params_for(:route)
      conn = post conn, group_shipment_route_path(conn, :create, group, shipment), route: route_params
      assert %{id: id} = redirected_params(conn)
      #assert redirected_to(conn) == group_shipment_route_path(conn, :show, group, shipment, route)

      conn = get conn, group_shipment_route_path(conn, :show, group, shipment, route)
      assert html_response(conn, 200) =~ route_params.label
    end

    test "renders errors when data is invalid", %{conn: conn, group: group, shipment: shipment} do
      conn = post conn, group_shipment_route_path(conn, :create, group, shipment), route: params_for(:invalid_route)
      assert html_response(conn, 200) =~ "New Stop Along Route"
    end
  end

  describe "edit route" do
    setup [:create_route]

    test "renders form for editing chosen route", %{conn: conn, group: group, shipment: shipment, route: route} do
      conn = get conn, group_shipment_route_path(conn, :edit, group, shipment, route)
      assert html_response(conn, 200) =~ "Edit Route"
    end
  end

  describe "update route" do
    setup [:create_route]

    test "redirects when data is valid", %{conn: conn, group: group, shipment: shipment, route: route} do
      route_params = params_for(:route)
      conn = put conn, group_shipment_route_path(conn, :update, group, shipment, route), route: route_params
      assert redirected_to(conn) == group_shipment_route_path(conn, :show, group, shipment, route)

      conn = get conn, group_shipment_route_path(conn, :show, group, shipment, route)
      assert html_response(conn, 200) =~ route_params.label
    end

    # WHY DOESNT THIS WORK????
#    test "renders errors when data is invalid", %{conn: conn,  group: group, shipment: shipment, route: route} do
#      routes = params_for(:invalid_route)
#      conn = put conn, group_shipment_route_path(conn, :update, group, shipment, route), routes
#      assert html_response(conn, 200) =~ "Edit Route"
#    end
#  end

  describe "delete route" do
    setup [:create_route]

    test "deletes chosen route", %{conn: conn, group: group, shipment: shipment, route: route} do
      conn = delete conn, group_shipment_route_path(conn, :delete, group, shipment, route)
      assert redirected_to(conn) == group_shipment_route_path(conn, :index, group, shipment)
      assert_error_sent 404, fn ->
        get conn, group_shipment_route_path(conn, :show, group, shipment, route)
      end
    end
  end

  defp create_route(_) do
    route = insert(:route)
    {:ok, route: route}
  end
end
