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
end
