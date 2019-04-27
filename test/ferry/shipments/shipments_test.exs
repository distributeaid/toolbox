defmodule Ferry.ShipmentsTest do
  use Ferry.DataCase

  alias Ferry.Shipments

  describe "shipments" do
    alias Ferry.Shipments.Shipment

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def shipment_fixture(attrs \\ %{}) do
      {:ok, shipment} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Shipments.create_shipment()

      shipment
    end

    test "list_shipments/0 returns all shipments" do
      shipment = shipment_fixture()
      assert Shipments.list_shipments() == [shipment]
    end

    test "get_shipment!/1 returns the shipment with given id" do
      shipment = shipment_fixture()
      assert Shipments.get_shipment!(shipment.id) == shipment
    end

    test "create_shipment/1 with valid data creates a shipment" do
      assert {:ok, %Shipment{} = shipment} = Shipments.create_shipment(@valid_attrs)
    end

    test "create_shipment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Shipments.create_shipment(@invalid_attrs)
    end

    test "update_shipment/2 with valid data updates the shipment" do
      shipment = shipment_fixture()
      assert {:ok, shipment} = Shipments.update_shipment(shipment, @update_attrs)
      assert %Shipment{} = shipment
    end

    test "update_shipment/2 with invalid data returns error changeset" do
      shipment = shipment_fixture()
      assert {:error, %Ecto.Changeset{}} = Shipments.update_shipment(shipment, @invalid_attrs)
      assert shipment == Shipments.get_shipment!(shipment.id)
    end

    test "delete_shipment/1 deletes the shipment" do
      shipment = shipment_fixture()
      assert {:ok, %Shipment{}} = Shipments.delete_shipment(shipment)
      assert_raise Ecto.NoResultsError, fn -> Shipments.get_shipment!(shipment.id) end
    end

    test "change_shipment/1 returns a shipment changeset" do
      shipment = shipment_fixture()
      assert %Ecto.Changeset{} = Shipments.change_shipment(shipment)
    end
  end
end
