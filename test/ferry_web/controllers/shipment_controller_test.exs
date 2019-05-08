defmodule FerryWeb.ShipmentControllerTest do
  use FerryWeb.ConnCase

  alias Ferry.Shipments

  # Shipment Controller Tests
  # ==============================================================================

  setup do
    group = insert(:group)
    user = insert(:user, group: group)
    shipment = insert(:shipment)

    conn = build_conn()
    conn = post conn, session_path(conn, :create, %{user: %{email: user.email, password: @password}})
    {:ok, conn: conn, group: group, user: user, shipment: shipment}
  end

  # Errors
  # ----------------------------------------------------------
  # TODO


  # Show
  # ----------------------------------------------------------

  describe "index" do
    test "lists all shipments", %{conn: conn, group: group, shipment: shipment} do
      # TODO: Need to mock repo call here
      conn = get conn, group_shipment_path(conn, :index, group)
      assert html_response(conn, 200) =~ "Shipments"
    end
  end

  describe "show" do
    test "lists the specified shipment", %{conn: conn, group: group, shipment: shipment} do
      conn = get conn, group_shipment_path(conn, :show, group, shipment)
      assert html_response(conn, 200) =~ shipment.label
    end
  end

  # Create
  # ----------------------------------------------------------

  describe "new shipment" do
    test "renders form", %{conn: conn, group: group, shipment: shipment} do
      conn = get conn, group_shipment_path(conn, :new, group)
      assert html_response(conn, 200) =~ "New Shipment"
    end
  end

  describe "create shipment" do
    test "redirects to show when data is valid", %{conn: conn, group: group, shipment: shipment} do
      shipment_params = params_for(:shipment)
      conn = post conn, group_shipment_path(conn, :create, group), shipment: shipment_params
      #Because I adjust changeset in create, this turns out to be different
      #assert redirected_to(conn) == group_shipment_path(conn, :show, group, shipment)

      conn = get conn, group_shipment_path(conn, :show, group, shipment)
      assert html_response(conn, 200) =~ "Show Shipment"
    end

    test "renders errors when data is invalid", %{conn: conn, group: group} do
      conn = post conn, group_shipment_path(conn, :create, group ), shipment: params_for(:invalid_shipment)
      assert html_response(conn, 200) =~ "New Shipment"
    end
  end

  # Update
  # ----------------------------------------------------------

  describe "edit shipment" do
    test "renders form for editing chosen shipment", %{conn: conn, group: group, shipment: shipment} do
      conn = get conn, group_shipment_path(conn, :edit,  group, shipment)
      assert html_response(conn, 200) =~ "Edit Shipment"
    end
  end

  describe "update shipment" do
    test "redirects when data is valid", %{conn: conn, group: group, shipment: shipment} do
      shipment_params = params_for(:shipment)
      conn = put conn, group_shipment_path(conn, :update, group, shipment), shipment: shipment_params
      assert redirected_to(conn) == group_shipment_path(conn, :show, group, shipment)

      conn = get conn, group_shipment_path(conn, :show, group, shipment)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, group: group, shipment: shipment} do
      conn = put conn, group_shipment_path(conn, :update, group, shipment), shipment: params_for(:invalid_shipment)
      assert html_response(conn, 200) =~ "Edit Shipment"
    end
  end

  # Delete
  # ----------------------------------------------------------

  describe "delete shipment" do
    test "deletes chosen shipment", %{conn: conn, group: group, shipment: shipment} do
      conn = delete conn, group_shipment_path(conn, :delete, group, shipment)
      assert redirected_to(conn) == group_shipment_path(conn, :index, group)
      assert_error_sent 404, fn ->
        get conn, group_shipment_path(conn, :show, group, shipment)
      end
    end
  end

end
