defmodule FerryWeb.RoleControllerTest do
  use FerryWeb.ConnCase


  # Role Controller Tests
  # ================================================================================
  
  setup do
    group = insert(:group)
    user = insert(:user, group: group)
    shipment = insert(:shipment)
    role = insert(:shipment_role, %{group: group, shipment: shipment})

    conn = build_conn()
    conn = post conn, session_path(conn, :create, %{user: %{email: user.email, password: @password}})
    {:ok, conn: conn, group: group, user: user, shipment: shipment, role: role}
  end

  # Errors
  # ----------------------------------------------------------
  # TODO


  # Show
  # ----------------------------------------------------------

  # describe "index" do
  #   test "lists all roles", %{conn: conn} do
  #     conn = get conn, role_path(conn, :index)
  #     assert html_response(conn, 200) =~ "Listing Shipments groups roles"
  #   end
  # end
  #
  # describe "show"

  # Create
  # ----------------------------------------------------------

  describe "new role" do
    test "renders form", %{conn: conn, group: group, shipment: shipment} do
      conn = get conn, group_shipment_role_path(conn, :new, group, shipment)
      assert html_response(conn, 200) =~ "New Role"
    end
  end

  describe "create role" do
    test "redirects to show when data is valid", %{conn: conn, group: group, shipment: shipment} do
      role_attrs = string_params_for(:shipment_role, %{
        group_id: insert(:group).id,
        shipment_id: shipment.id
      })
      conn = post conn, group_shipment_role_path(conn, :create, group, shipment), role: role_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == group_shipment_path(conn, :show, group, shipment)

      conn = get conn, group_shipment_path(conn, :show, group, shipment)
      assert html_response(conn, 200) =~ role_attrs["description"]
    end

    test "renders errors when data is invalid", %{conn: conn, group: group, shipment: shipment} do
      role_attrs = string_params_for(:invalid_shipment_role, %{
        group_id: insert(:group).id,
        shipment_id: shipment.id
      })
      conn = post conn, group_shipment_role_path(conn, :create, group, shipment), role: role_attrs
      assert html_response(conn, 200) =~ "New Role"
    end
  end

  # Update
  # ----------------------------------------------------------

  describe "edit role" do
    test "renders form for editing chosen role", %{conn: conn, group: group, shipment: shipment, role: role} do
      conn = get conn, group_shipment_role_path(conn, :edit, group, shipment, role)
      assert html_response(conn, 200) =~ "Edit Role"
    end
  end

  describe "update role" do
    test "redirects when data is valid", %{conn: conn, group: group, shipment: shipment, role: role} do
      role_attrs = string_params_for(:shipment_role)
      conn = put conn, group_shipment_role_path(conn, :update, group, shipment, role), role: role_attrs
      assert redirected_to(conn) == group_shipment_path(conn, :show, group, shipment)

      conn = get conn, group_shipment_path(conn, :show, group, shipment)
      assert html_response(conn, 200) =~ role_attrs["description"]
    end

    test "renders errors when data is invalid", %{conn: conn, group: group, shipment: shipment, role: role} do
      role_attrs = string_params_for(:invalid_shipment_role)
      conn = put conn, group_shipment_role_path(conn, :update, group, shipment, role), role: role_attrs
      assert html_response(conn, 200) =~ "Edit Role"
    end
  end

  # Delete
  # ----------------------------------------------------------

  describe "delete role" do
    test "deletes chosen role", %{conn: conn, group: group, shipment: shipment, role: role} do
      group2 = insert(:group)
      role2 = insert(:shipment_role, %{group: group2, shipment: shipment})

      conn = delete conn, group_shipment_role_path(conn, :delete, group, shipment, role)
      assert redirected_to(conn) == group_shipment_path(conn, :show, group, shipment)

      conn = get conn, group_shipment_path(conn, :show, group, shipment)
      refute html_response(conn, 200) =~ role.description
      assert html_response(conn, 200) =~ role2.description
    end

    test "renders errors when deletion is invalid", %{conn: conn, group: group, shipment: shipment, role: role} do
      conn = delete conn, group_shipment_role_path(conn, :delete, group, shipment, role)
      assert redirected_to(conn) == group_shipment_path(conn, :show, group, shipment)

      conn = get conn, group_shipment_path(conn, :show, group, shipment)
      assert html_response(conn, 200) =~ "There must be at least 1 group taking part in this shipment."
    end
  end
end
