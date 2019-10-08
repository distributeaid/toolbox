defmodule FerryWeb.RouteControllerTest do
  use FerryWeb.ConnCase


  # Route Controller Tests
  # ================================================================================

  setup do
    group = insert(:group)
    user = insert(:user, group: group)
    shipment = insert(:shipment)
    route = insert(:route, %{shipment: shipment})

    conn = build_conn()
    conn = post conn, Routes.session_path(conn, :create, %{user: %{email: user.email, password: @password}})
    {:ok, conn: conn, group: group, user: user, shipment: shipment, route: route}
  end

  # Errors
  # ----------------------------------------------------------
  # TODO

  # Create
  # ----------------------------------------------------------

  describe "new route" do
    test "renders form", %{conn: conn, group: group, shipment: shipment} do
      conn = get conn, Routes.group_shipment_route_path(conn, :new, group, shipment)
      assert html_response(conn, 200) =~ "Add A New Route Stop"
    end
  end

  describe "create route" do
    test "redirects to show when data is valid", %{conn: conn, group: group, shipment: shipment} do
      route_params = params_for(:route)
      conn = post conn, Routes.group_shipment_route_path(conn, :create, group, shipment), route: route_params
      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.group_shipment_path(conn, :show, group, shipment)

      conn = get conn, Routes.group_shipment_path(conn, :show, group, shipment)
      assert html_response(conn, 200) =~ route_params.address
    end

    test "renders errors when data is invalid", %{conn: conn, group: group, shipment: shipment} do
      conn = post conn, Routes.group_shipment_route_path(conn, :create, group, shipment), route: params_for(:invalid_route)
      assert html_response(conn, 200) =~ "Add A New Route Stop"
    end
  end

  # Update
  # ----------------------------------------------------------

  describe "edit route" do
    test "renders form for editing chosen route", %{conn: conn, group: group, shipment: shipment, route: route} do
      conn = get conn, Routes.group_shipment_route_path(conn, :edit, group, shipment, route)
      assert html_response(conn, 200) =~ "Edit A Route Stop"
    end
  end

  describe "update route" do
    test "redirects when data is valid", %{conn: conn, group: group, shipment: shipment, route: route} do
      route_params = params_for(:route)
      conn = put conn, Routes.group_shipment_route_path(conn, :update, group, shipment, route), route: route_params
      assert redirected_to(conn) == Routes.group_shipment_path(conn, :show, group, shipment)

      conn = get conn, Routes.group_shipment_path(conn, :show, group, shipment)
      assert html_response(conn, 200) =~ route_params.address
    end

    test "renders errors when data is invalid", %{conn: conn,  group: group, shipment: shipment, route: route} do
      conn = put conn, Routes.group_shipment_route_path(conn, :update, group, shipment, route), route: params_for(:invalid_route)
      assert html_response(conn, 200) =~ "Edit A Route Stop"
    end
  end

  # Delete
  # ----------------------------------------------------------

  describe "delete route" do
    test "deletes chosen route", %{conn: conn, group: group, shipment: shipment, route: route} do
      conn = delete conn, Routes.group_shipment_route_path(conn, :delete, group, shipment, route)
      assert redirected_to(conn) == Routes.group_shipment_path(conn, :show, group, shipment)

      conn = get conn, Routes.group_shipment_path(conn, :show, group, shipment)
      refute html_response(conn, 200) =~ route.address
    end
  end
end
