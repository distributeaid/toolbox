defmodule FerryWeb.ShipmentControllerTest do
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
    test "lists all shipments", %{conn: conn, group: group} do
      conn = get conn, Routes.group_shipment_path(conn, :index, group)
      assert html_response(conn, 200) =~ "Shipments"
    end
  end

  describe "show" do
    test "lists the specified shipment", %{conn: conn, group: group, shipment: shipment} do
      conn = get conn, Routes.group_shipment_path(conn, :show, group, shipment)
      assert html_response(conn, 200) =~ shipment.label
    end
  end

  # Create
  # ----------------------------------------------------------

  describe "new shipment" do
    test "renders form", %{conn: conn, group: group} do
      conn = get conn, Routes.group_shipment_path(conn, :new, group)
      assert html_response(conn, 200) =~ "New Shipment"
    end
  end

  describe "create shipment" do
    test "redirects to show when data is valid", %{conn: conn, group: group} do
      shipment_params = params_for(:shipment) |> Map.put("new_route", "false")
      conn = post conn, Routes.group_shipment_path(conn, :create, group), shipment: shipment_params

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.group_shipment_path(conn, :show, group, id)

      conn = get conn, Routes.group_shipment_path(conn, :show, group, id)
      assert html_response(conn, 200) =~ shipment_params.label

      shipment_params =  Map.put(shipment_params, "new_route", "true")
      assert html_response(conn, 200) =~ shipment_params.label
    end

    test "renders errors when data is invalid", %{conn: conn, group: group} do
      shipment_params = params_for(:invalid_shipment) |> Map.put("new_route", "false")
      conn = post conn, Routes.group_shipment_path(conn, :create, group ), shipment: shipment_params
      assert html_response(conn, 200) =~ "New Shipment"
    end
  end

  # Update
  # ----------------------------------------------------------

  describe "edit shipment" do
    test "renders form for editing chosen shipment", %{conn: conn, group: group, shipment: shipment} do
      conn = get conn, Routes.group_shipment_path(conn, :edit,  group, shipment)
      assert html_response(conn, 200) =~ "Edit A Shipment"
    end
  end

  describe "update shipment" do
    test "redirects when data is valid", %{conn: conn, group: group, shipment: shipment} do
      shipment_params = params_for(:shipment)
      conn = put conn, Routes.group_shipment_path(conn, :update, group, shipment), shipment: shipment_params
      assert redirected_to(conn) == Routes.group_shipment_path(conn, :show, group, shipment)

      conn = get conn, Routes.group_shipment_path(conn, :show, group, shipment)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, group: group, shipment: shipment} do
      shipment_params = params_for(:invalid_shipment) |> Map.put("new_route", "false")

      conn = put conn, Routes.group_shipment_path(conn, :update, group, shipment), shipment: shipment_params
      assert html_response(conn, 200) =~ "Edit A Shipment"
    end
  end

  # Delete
  # ----------------------------------------------------------

  describe "delete shipment" do
    test "deletes chosen shipment", %{conn: conn, group: group, shipment: shipment} do
      conn = delete conn, Routes.group_shipment_path(conn, :delete, group, shipment)
      assert redirected_to(conn) == Routes.group_shipment_path(conn, :index, group)
      assert_error_sent 404, fn ->
        get conn, Routes.group_shipment_path(conn, :show, group, shipment)
      end
    end
  end

end
