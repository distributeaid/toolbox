defmodule FerryWeb.AddressControllerTest do
  use FerryWeb.ConnCase

  # Address Controller Tests
  # ==============================================================================

  setup do
    group = insert(:group)
    user = insert(:user, group: group)
    address = insert(:address, group: group)

    conn = build_conn()
    conn = post conn, session_path(conn, :create, %{user: %{email: user.email, password: @password}})
    {:ok, conn: conn, group: group, user: user, address: address}
  end

  # Errors
  # ----------------------------------------------------------

  describe "errors" do
    test "shows 401 unauthorized for non-logged-in users", %{group: group, address: address} do
      Enum.each(
        [
          get(build_conn(), group_address_path(build_conn(), :new, group)),
          post(build_conn(), group_address_path(build_conn(), :create, group), address: params_for(:address)),
          get(build_conn(), group_address_path(build_conn(), :edit, group, address)),
          put(build_conn(), group_address_path(build_conn(), :update, group, address), group: params_for(:address)),
          delete(build_conn(), group_address_path(build_conn(), :delete, group, address))
        ],
        fn conn -> assert conn.status == 401 end
      )
    end

    # NOTE: This covers the case of authenticated 404 errors for these actions,
    #       since the user will be unauthenticated for the non-existant group.
    test "shows 403 unauthenticated for actions on unassociated addresses", %{conn: conn} do
      not_my_group = insert(:group)
      not_my_address = insert(:address, group: not_my_group)

      Enum.each(
        [
          # authenticated
          post(conn, group_address_path(conn, :create, not_my_group), address: params_for(:address)),
          get(conn, group_address_path(conn, :new, not_my_group)),
          get(conn, group_address_path(conn, :edit, not_my_group, not_my_address)),
          put(conn, group_address_path(conn, :update, not_my_group, not_my_address), address: params_for(:address)),
          delete(conn, group_address_path(conn, :delete, not_my_group, not_my_address))
        ],
        fn conn -> assert conn.status == 403 end
      )
    end

    test "shows 404 not found for non-existent groups", %{conn: conn, address: address} do
      Enum.each(
        [
          # unauthenticated
          fn -> get build_conn(), group_address_path(build_conn(), :index, 1312) end,
          fn -> get build_conn(), group_address_path(build_conn(), :show, 1312, address) end,

          # authenticated
          fn -> get conn, group_address_path(conn, :index, 1312) end,
          fn -> get conn, group_address_path(conn, :show, 1312, address) end,
        ],
        fn request -> assert_error_sent 404, request end
      )
    end

    test "shows 404 not found for non-existent addresses", %{conn: conn, group: group} do
      Enum.each(
        [
          # unauthenticated
          fn -> get build_conn(), group_address_path(build_conn(), :show, group, 1312) end,

          # authenticated
          fn -> get conn, group_address_path(conn, :show, group, 1312) end,
          fn -> get conn, group_address_path(conn, :edit, group, 1312) end,
          fn -> put conn, group_address_path(conn, :update, group, 1312), address: params_for(:address) end,
          fn -> delete conn, group_address_path(conn, :delete, group, 1312) end

        ],
        fn request -> assert_error_sent 404, request end
      )
    end
  end

  # Show
  # ----------------------------------------------------------

  describe "index" do
    # TODO: actually lists no addresses since none are created... test both cases
    test "lists all addresses", %{conn: conn, group: group} do
      conn = get conn, group_address_path(conn, :index, group)
      assert html_response(conn, 200) =~ "Addresses"
    end
  end

  describe "show" do
    test "lists the specified address", %{conn: conn, group: group, address: address} do
      conn = get conn, group_address_path(conn, :show, group, address)
      assert html_response(conn, 200) =~ "Show Address"
    end
  end

  # Create
  # ----------------------------------------------------------

  describe "new address" do
    test "renders form", %{conn: conn, group: group} do
      conn = get conn, group_address_path(conn, :new, group)
      assert html_response(conn, 200) =~ "New Address"
    end
  end

  describe "create address" do
    test "redirects to show when data is valid", %{conn: conn, group: group} do
      conn = post conn, group_address_path(conn, :create, group), address: params_for(:address)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == group_address_path(conn, :show, group, id)

      conn = get conn, group_address_path(conn, :show, group, id)
      assert html_response(conn, 200) =~ "Show Address"
    end

    test "renders errors when data is invalid", %{conn: conn, group: group} do
      conn = post conn, group_address_path(conn, :create, group), address: params_for(:invalid_address)
      assert html_response(conn, 200) =~ "New Address"
    end
  end

  # Update
  # ----------------------------------------------------------

  describe "edit address" do
    test "renders form for editing chosen address", %{conn: conn, group: group, address: address} do
      conn = get conn, group_address_path(conn, :edit, group, address)
      assert html_response(conn, 200) =~ "Edit Address"
    end
  end

  describe "update address" do
    test "redirects when data is valid", %{conn: conn, group: group, address: address} do
      conn = put conn, group_address_path(conn, :update, group, address), address: params_for(:address)
      assert redirected_to(conn) == group_address_path(conn, :show, group, address)

      conn = get conn, group_address_path(conn, :show, group, address)
      assert html_response(conn, 200) =~ "Show Address"
    end

    test "renders errors when data is invalid", %{conn: conn, group: group, address: address} do
      conn = put conn, group_address_path(conn, :update, group, address), address: params_for(:invalid_address)
      assert html_response(conn, 200) =~ "Edit Address"
    end
  end

  # Delete
  # ----------------------------------------------------------

  describe "delete address" do
    test "deletes chosen address", %{conn: conn, group: group, address: address} do
      conn = delete conn, group_address_path(conn, :delete, group, address)
      assert redirected_to(conn) == group_address_path(conn, :index, group)
      assert_error_sent 404, fn ->
        get conn, group_address_path(conn, :show, group, address)
      end
    end
  end

end
