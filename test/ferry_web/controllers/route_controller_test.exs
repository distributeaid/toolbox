defmodule FerryWeb.RouteControllerTest do
  use FerryWeb.ConnCase

  alias Ferry.Shipments

  @create_attrs %{address: "some address", date: "some date", groups: "some groups"}
  @update_attrs %{address: "some updated address", date: "some updated date", groups: "some updated groups"}
  @invalid_attrs %{address: nil, date: nil, groups: nil}

  def fixture(:route) do
    {:ok, route} = Shipments.create_route(@create_attrs)
    route
  end

  describe "index" do
    test "lists all routes", %{conn: conn} do
      conn = get conn, group_shipment_route_path(conn, :index, group, shipment))
      assert html_response(conn, 200) =~ "Listing Routes"
    end
  end

  describe "new route" do
    test "renders form", %{conn: conn} do
      conn = get conn, group_shipment_route_path(conn, :new)
      assert html_response(conn, 200) =~ "New Route"
    end
  end

  describe "create route" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, group_shipment_route_path(conn, :create), route: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == group_shipment_route_path(conn, :show, id)

      conn = get conn, group_shipment_route_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Route"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, group_shipment_route_path(conn, :create), route: @invalid_attrs
      assert html_response(conn, 200) =~ "New Route"
    end
  end

  describe "edit route" do
    setup [:create_route]

    test "renders form for editing chosen route", %{conn: conn, route: route} do
      conn = get conn, group_shipment_route_path(conn, :edit, group, shipment, route)
      assert html_response(conn, 200) =~ "Edit Route"
    end
  end

  describe "update route" do
    setup [:create_route]

    test "redirects when data is valid", %{conn: conn, route: route} do
      conn = put conn, group_shipment_route_path(conn, :update, route), route: @update_attrs
      assert redirected_to(conn) == group_shipment_route_path(conn, :show, route)

      conn = get conn, group_shipment_route_path(conn, :show, route)
      assert html_response(conn, 200) =~ "some updated address"
    end

    test "renders errors when data is invalid", %{conn: conn, route: route} do
      conn = put conn, group_shipment_route_path(conn, :update, route), route: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Route"
    end
  end

  describe "delete route" do
    setup [:create_route]

    test "deletes chosen route", %{conn: conn, route: route} do
      conn = delete conn, group_shipment_route_path(conn, :delete, route)
      assert redirected_to(conn) == group_shipment_route_path(conn, :index, group, shipment))
      assert_error_sent 404, fn ->
        get conn, group_shipment_route_path(conn, :show, route)
      end
    end
  end

  defp create_route(_) do
    route = fixture(:route)
    {:ok, route: route}
  end
end
