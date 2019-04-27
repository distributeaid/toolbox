defmodule FerryWeb.ShipmentControllerTest do
  use FerryWeb.ConnCase

  alias Ferry.Shipments

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:shipment) do
    {:ok, shipment} = Shipments.create_shipment(@create_attrs)
    shipment
  end

  describe "index" do
    test "lists all shipments", %{conn: conn} do
      conn = get conn, group_shipment_path(conn, :index, 1)
      assert html_response(conn, 200) =~ "Listing Shipments"
    end
  end

  describe "new shipment" do
    test "renders form", %{conn: conn} do
      conn = get conn, group_shipment_path(conn, :new, 1)
      assert html_response(conn, 200) =~ "New Shipment"
    end
  end

  describe "create shipment" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, group_shipment_path(conn, :create, 1), shipment: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == group_shipment_path(conn, :show, 1, id)

      conn = get conn, group_shipment_path(conn, :show, 1, id)
      assert html_response(conn, 200) =~ "Show Shipment"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, group_shipment_path(conn, :create, 1), shipment: @invalid_attrs
      assert html_response(conn, 200) =~ "New Shipment"
    end
  end

  describe "edit shipment" do
    setup [:create_shipment]

    test "renders form for editing chosen shipment", %{conn: conn, shipment: shipment} do
      conn = get conn, group_shipment_path(conn, :edit,  1, shipment)
      assert html_response(conn, 200) =~ "Edit Shipment"
    end
  end

  describe "update shipment" do
    setup [:create_shipment]

    test "redirects when data is valid", %{conn: conn, shipment: shipment} do
      conn = put conn, group_shipment_path(conn, :update, 1, shipment), shipment: @update_attrs
      assert redirected_to(conn) == group_shipment_path(conn, :show, 1, shipment)

      conn = get conn, group_shipment_path(conn, :show, 1, shipment)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, shipment: shipment} do
      conn = put conn, group_shipment_path(conn, :update, 1, shipment), shipment: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Shipment"
    end
  end

  describe "delete shipment" do
    setup [:create_shipment]

    test "deletes chosen shipment", %{conn: conn, shipment: shipment} do
      conn = delete conn, group_shipment_path(conn, :delete, 1, shipment)
      assert redirected_to(conn) == group_shipment_path(conn, 1, :index)
      assert_error_sent 404, fn ->
        get conn, group_shipment_path(conn, :show, 1, shipment)
      end
    end
  end

  defp create_shipment(_) do
    shipment = fixture(:shipment)
    {:ok, shipment: shipment}
  end
end
