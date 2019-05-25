defmodule Ferry.ShipmentsTest do
  use Ferry.DataCase

  alias Ferry.Shipments

  describe "shipments" do
    alias Ferry.Shipments.Shipment


    test "list_shipments/0 returns all shipments" do
      shipment = insert(:shipment)
      assert Shipments.list_shipments() == [shipment]
    end

    test "get_shipment!/1 returns the shipment with given id" do
      shipment = insert(:shipment)
      assert Shipments.get_shipment!(shipment.id) == shipment
    end

    test "create_shipment/1 with valid data creates a shipment" do
      assert {:ok, %Shipment{} = shipment} = Shipments.create_shipment(%{"target_date_to_be_shipped" => "today", "group_id" => 5, "label" => "hereComesTheSun"})
    end

    test "create_shipment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Shipments.create_shipment(%{"target_date_to_be_shipped" => "today"})
    end

    test "update_shipment/2 with valid data updates the shipment" do
      shipment = insert(:shipment)
      assert {:ok, shipment} = Shipments.update_shipment(shipment, %{"target_date_to_be_shipped" => "today", "group_id" => 5})
      assert %Shipment{} = shipment
    end

    test "update_shipment/2 with invalid data returns error changeset" do
      shipment = insert(:shipment)
      assert {:error, %Ecto.Changeset{}} = Shipments.update_shipment(shipment, %{"group_id" => "notAnInt"})
      assert shipment == Shipments.get_shipment!(shipment.id)
    end

    test "delete_shipment/1 deletes the shipment" do
      shipment = insert(:shipment)
      assert {:ok, %Shipment{}} = Shipments.delete_shipment(shipment)
      assert_raise Ecto.NoResultsError, fn -> Shipments.get_shipment!(shipment.id) end
    end

    test "change_shipment/1 returns a shipment changeset" do
      shipment = insert(:shipment)
      assert %Ecto.Changeset{} = Shipments.change_shipment(shipment)
    end
  end

  describe "routes" do
    alias Ferry.Shipments.Shipment
    alias Ferry.Shipments.Route

    test "list_routes/0 returns all routes" do
      route = insert(:route)
      assert Shipments.list_routes() |> Ferry.Repo.preload(:shipment) == [route]
    end

    test "get_route!/1 returns the route with given id" do
      route = insert(:route)
      assert Shipments.get_route!(route.id) |> Ferry.Repo.preload(:shipment) == route
    end

    test "create_route/1 with valid data creates a route" do
      shipment = insert(:shipment)

      route_params = params_for(:route, %{shipment_id: shipment.id})

      assert {:ok, %Route{} = route} = Shipments.create_route(route_params)
      assert route.checklist == route_params.checklist
      assert route.date == route_params.date
      assert route.groups == route_params.groups
    end

    test "create_route/1 with invalid data returns error changeset" do
      route_params = params_for(:invalid_route)
      assert {:error, %Ecto.Changeset{}} = Shipments.create_route(route_params)
    end

    test "update_route/2 with valid data updates the route" do
      route = insert(:route)
      route_params = params_for(:route)
      assert {:ok, route} = Shipments.update_route(route, route_params)
      assert %Route{} = route
      assert route.label == route_params.label
#      assert route.date == "some updated date"
#      assert route.groups == "some updated groups"
    end

    test "update_route/2 with invalid data returns error changeset" do
      route = insert(:route)
      route_params = params_for(:invalid_route)
      assert {:error, %Ecto.Changeset{}} = Shipments.update_route(route, route_params)
      assert route == Shipments.get_route!(route.id) |> Ferry.Repo.preload(:shipment)
    end

    test "delete_route/1 deletes the route" do
      route = insert(:route)
      assert {:ok, %Route{}} = Shipments.delete_route(route)
      assert_raise Ecto.NoResultsError, fn -> Shipments.get_route!(route.id) end
    end

    test "change_route/1 returns a route changeset" do
      route = insert(:route)
      assert %Ecto.Changeset{} = Shipments.change_route(route)
    end
  end
end
