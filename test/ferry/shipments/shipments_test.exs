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
    alias Ferry.Shipments.Route

    @valid_attrs %{address: "some address", date: "some date", groups: "some groups"}
    @update_attrs %{address: "some updated address", date: "some updated date", groups: "some updated groups"}
    @invalid_attrs %{address: nil, date: nil, groups: nil}

    def route_fixture(attrs \\ %{}) do
      {:ok, route} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Shipments.create_route()

      route
    end

    test "list_routes/0 returns all routes" do
      route = route_fixture()
      assert Shipments.list_routes() == [route]
    end

    test "get_route!/1 returns the route with given id" do
      route = route_fixture()
      assert Shipments.get_route!(route.id) == route
    end

    test "create_route/1 with valid data creates a route" do
      assert {:ok, %Route{} = route} = Shipments.create_route(@valid_attrs)
      assert route.address == "some address"
      assert route.date == "some date"
      assert route.groups == "some groups"
    end

    test "create_route/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Shipments.create_route(@invalid_attrs)
    end

    test "update_route/2 with valid data updates the route" do
      route = route_fixture()
      assert {:ok, route} = Shipments.update_route(route, @update_attrs)
      assert %Route{} = route
      assert route.address == "some updated address"
      assert route.date == "some updated date"
      assert route.groups == "some updated groups"
    end

    test "update_route/2 with invalid data returns error changeset" do
      route = route_fixture()
      assert {:error, %Ecto.Changeset{}} = Shipments.update_route(route, @invalid_attrs)
      assert route == Shipments.get_route!(route.id)
    end

    test "delete_route/1 deletes the route" do
      route = route_fixture()
      assert {:ok, %Route{}} = Shipments.delete_route(route)
      assert_raise Ecto.NoResultsError, fn -> Shipments.get_route!(route.id) end
    end

    test "change_route/1 returns a route changeset" do
      route = route_fixture()
      assert %Ecto.Changeset{} = Shipments.change_route(route)
    end
  end
end
