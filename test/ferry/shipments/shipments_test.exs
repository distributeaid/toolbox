defmodule Ferry.ShipmentsTest do
  use Ferry.DataCase

  alias Ferry.Shipments
  alias Ferry.Shipments.Role
  alias Ferry.Shipments.Shipment

  # Helpers
  # ------------------------------------------------------------
  def without_assoc(list, field) when is_list(list) do
    Enum.map(list, fn x ->
      Map.delete(x, field)
    end)
  end

  def without_assoc(%{} = struct, field) do
    Map.delete(struct, field)
  end

  # Shipments
  # ==============================================================================
  describe "shipments" do
    test "list_shipments/0 returns all shipments" do
      # no shipments
      assert Shipments.list_shipments() == []

      # 1 shipment
      shipment1 = insert(:shipment)
      assert Shipments.list_shipments() == [shipment1]

      # n shipments
      shipment2 = insert(:shipment)
      assert Shipments.list_shipments() == [shipment1, shipment2]

      # roles should also be included if they exist
      shipment3 = insert(:shipment) |> with_role() |> with_role()
      assert Shipments.list_shipments() == [shipment1, shipment2, shipment3]
    end

    test "list_shipments/0 returns all shipments for a group" do
      group = insert(:group)
      group2 = insert(:group)

      # no shipments
      assert Shipments.list_shipments(group) == []

      # 1 shipment
      shipment1 = insert(:shipment) |> with_role(group)
      assert Shipments.list_shipments(group) == [shipment1]
      assert Shipments.list_shipments(group2) == []

      # n shipments
      shipment2 = insert(:shipment) |> with_role(group)
      assert Shipments.list_shipments(group) == [shipment1, shipment2]
      assert Shipments.list_shipments(group2) == []

      # only shipments for that group
      shipment3 = insert(:shipment) |> with_role(group2)
      assert Shipments.list_shipments(group) == [shipment1, shipment2]
      assert Shipments.list_shipments(group2) == [shipment3]

      # includes shipments with multiple groups involved
      shipment4 = insert(:shipment) |> with_role(group) |> with_role(group2)
      assert Shipments.list_shipments(group) == [shipment1, shipment2, shipment4]
      assert Shipments.list_shipments(group2) == [shipment3, shipment4]
    end

    test "get_shipment!/1 returns the shipment with given id" do
      created_shipment = insert(:shipment) |> with_role()
      shipment = Shipments.get_shipment!(created_shipment.id)
      assert shipment == created_shipment
      assert %Role{} = Enum.at(shipment.roles, 0) # make sure it includes the role
    end

    test "get_shipment!/1 with a non-existent id throws an error" do
      assert_raise Ecto.NoResultsError, ~r/^expected at least one result but got none in query/, fn ->
        Shipments.get_shipment!(1312)
      end
    end

    # TODO: force at least 1 role to exist to prevent orphan shipments
    test "create_shipment/1 with valid data creates a shipment" do
      attrs = params_for(:shipment)
      assert {:ok, %Shipment{} = shipment} = Shipments.create_shipment(attrs)
      assert shipment.label == attrs.label
      assert shipment.target_date_to_be_shipped == attrs.target_date_to_be_shipped
      assert shipment.status == attrs.status
      assert shipment.sender_address == attrs.sender_address
      assert shipment.items == attrs.items
      assert shipment.funding == attrs.funding
      assert shipment.receiver_address == attrs.receiver_address
      assert shipment.roles == []
    end

    test "create_shipment/1 with additional role data creates a shipment with roles" do
      group = insert(:group)
      role_attrs = params_for(:shipment_role, %{group_id: group.id})
      attrs = params_for(:shipment, %{roles: [role_attrs]})
      assert {:ok, %Shipment{} = shipment} = Shipments.create_shipment(attrs)
      assert [%Role{} = role] = shipment.roles

      # NOTE: shipment attributes are tested above, no need to duplicate here
      assert role.label == role_attrs.label
      assert role.description == role_attrs.description
      assert role.group_id == role_attrs.group_id
      assert role.shipment_id == shipment.id
    end

    test "create_shipment/1 with invalid data returns error changeset" do
      attrs = params_for(:invalid_shipment, %{})
      assert {:error, %Ecto.Changeset{}} = Shipments.create_shipment(attrs)
    end

    test "update_shipment/2 with valid data updates the shipment" do
      old_shipment = insert(:shipment)
      |> with_role()
      |> with_role()
      |> with_route()
      |> with_route()

      attrs = params_for(:shipment)

      assert {:ok, %Shipment{} = shipment} = Shipments.update_shipment(old_shipment, attrs)
      assert shipment.label == attrs.label
      assert shipment.target_date_to_be_shipped == attrs.target_date_to_be_shipped
      assert shipment.status == attrs.status
      assert shipment.sender_address == attrs.sender_address
      assert shipment.items == attrs.items
      assert shipment.funding == attrs.funding
      assert shipment.receiver_address == attrs.receiver_address
      assert shipment.roles == old_shipment.roles
      assert shipment.routes == old_shipment.routes
    end

    test "update_shipment/2 can't update roles" do
      old_shipment = insert(:shipment) |> with_role() |> with_role()
      attrs = params_for(:shipment)

      assert {:ok, %Shipment{} = shipment} = Shipments.update_shipment(old_shipment, attrs)
      assert shipment.label == attrs.label
      assert shipment.target_date_to_be_shipped == attrs.target_date_to_be_shipped
      assert shipment.status == attrs.status
      assert shipment.sender_address == attrs.sender_address
      assert shipment.items == attrs.items
      assert shipment.funding == attrs.funding
      assert shipment.receiver_address == attrs.receiver_address
      assert shipment.roles == old_shipment.roles
    end

    test "update_shipment/2 with invalid data returns error changeset" do
      shipment = insert(:shipment)
      attrs = params_for(:invalid_shipment)
      assert {:error, %Ecto.Changeset{}} = Shipments.update_shipment(shipment, attrs)
      assert shipment |> without_assoc(:routes)
          == Shipments.get_shipment!(shipment.id) |> without_assoc(:routes)
    end

    test "delete_shipment/1 deletes the shipment and roles" do
      shipment = insert(:shipment) |> with_role()
      assert {:ok, %Shipment{}} = Shipments.delete_shipment(shipment)
      assert_raise Ecto.NoResultsError, fn -> Shipments.get_shipment!(shipment.id) end
      assert_raise Ecto.NoResultsError, fn -> Shipments.get_role!(Enum.at(shipment.roles, 0).id) end
    end

    test "change_shipment/1 returns a shipment changeset" do
      shipment = insert(:shipment)
      assert %Ecto.Changeset{} = Shipments.change_shipment(shipment)
    end
  end

  # Roles
  # ==============================================================================
  describe "roles" do

    test "get_role!/1 returns the role with given id" do
      group = insert(:group)
      shipment = insert(:shipment)
      role = insert(:shipment_role, %{shipment_id: shipment.id, group: group})
      assert Shipments.get_role!(role.id) == role
    end

    test "get_role!/1 with a non-existent id throws an error" do
      assert_raise Ecto.NoResultsError, ~r/^expected at least one result but got none in query/, fn ->
        Shipments.get_role!(1312)
      end
    end

    test "create_role/3 with valid data creates a role" do
      group = insert(:group)
      shipment = insert(:shipment)
      attrs = params_for(:shipment_role)
      assert {:ok, %Role{} = role} = Shipments.create_role(group, shipment, attrs)
      assert role.label == attrs.label
      assert role.description == attrs.description
      assert role.group_id == group.id
      assert role.shipment_id == shipment.id
    end

    test "create_shipment/1 with invalid data returns error changeset" do
      group = insert(:group)
      shipment = insert(:shipment)
      attrs = params_for(:invalid_shipment_role, %{})
      assert {:error, %Ecto.Changeset{}} = Shipments.create_role(group, shipment, attrs)
    end

    # TODO: validate that you can't change the shipment / group
    test "update_role/2 with valid data updates the role" do
      group = insert(:group)
      shipment = insert(:shipment)
      old_role = insert(:shipment_role, %{shipment: shipment, group: group})
      attrs = params_for(:shipment_role)

      assert {:ok, %Role{} = role} = Shipments.update_role(old_role, attrs)
      assert role.label == attrs.label
      assert role.description == attrs.description
      assert role.group_id == group.id
      assert role.shipment_id == shipment.id
    end

    test "update_role/2 with invalid data returns error changeset" do
      group = insert(:group)
      shipment = insert(:shipment)
      role = insert(:shipment_role, %{shipment_id: shipment.id, group: group})
      attrs = params_for(:invalid_shipment_role)
      assert {:error, %Ecto.Changeset{}} = Shipments.update_role(role, attrs)
      assert role == Shipments.get_role!(role.id)
    end

    test "delete_role/1 deletes the role" do
      group = insert(:group)
      shipment = insert(:shipment)
      role = insert(:shipment_role, %{shipment: shipment, group: group})
      assert {:ok, %Role{}} = Shipments.delete_role(role)
      assert_raise Ecto.NoResultsError, fn -> Shipments.get_role!(role.id) end
    end

    test "change_role/1 returns a role changeset" do
      group = insert(:group)
      shipment = insert(:shipment)
      role = insert(:shipment_role, %{shipment: shipment, group: group})
      assert %Ecto.Changeset{} = Shipments.change_role(role)
    end
  end

  # Routes
  # ==============================================================================
  describe "routes" do
    alias Ferry.Shipments.Shipment
    alias Ferry.Shipments.Route

    test "list_routes/1 returns all routes in a shipment" do
      shipment = insert(:shipment)

      # no routes
      assert Shipments.list_routes(shipment) == []

      # 1 route
      route1 = insert(:route, %{shipment: shipment}) |> without_assoc(:shipment)
      routes = Shipments.list_routes(shipment) |> without_assoc(:shipment)
      assert routes == [route1]

      # n routes
      route2 = insert(:route, %{shipment: shipment}) |> without_assoc(:shipment)
      routes = Shipments.list_routes(shipment) |> without_assoc(:shipment)
      assert routes == [route1, route2]

      # only routes for that shipment should be included
      not_my_shipment = insert(:shipment)
      _not_my_route = insert(:route, %{shipment: not_my_shipment}) |> without_assoc(:shipment)
      routes = Shipments.list_routes(shipment) |> without_assoc(:shipment)
      assert routes == [route1, route2]
    end

    test "get_route!/1 returns the route with given id" do
      route = insert(:route) |> without_assoc(:shipment)
      assert Shipments.get_route!(route.id) |> without_assoc(:shipment) == route
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
    end

    test "update_route/2 with invalid data returns error changeset" do
      route = insert(:route)
      route_params = params_for(:invalid_route)
      assert {:error, %Ecto.Changeset{}} = Shipments.update_route(route, route_params)
      assert route |> without_assoc(:shipment)
          == Shipments.get_route!(route.id) |> without_assoc(:shipment)
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
