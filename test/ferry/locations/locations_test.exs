defmodule Ferry.LocationsTest do
  use Ferry.DataCase

  import Mox

  alias Ferry.Locations

  # Addresses
  # ==============================================================================
  describe "addresses" do
    alias Ferry.Locations.Address

    setup :verify_on_exit!

    # Tests
    # ----------------------------------------------------------

    test "list_addresses/1 returns all addresses for a group" do
      group = insert(:group)
      group2 = insert(:group)

      # no addresses
      assert Locations.list_addresses(group) == []

      # 1 address
      # |> with_geocode()
      address1 = insert(:address, group_id: group.id)
      assert Locations.list_addresses(group) == [address1]

      # n addresses
      # |> with_geocode()
      address2 = insert(:address, group_id: group.id)
      assert Locations.list_addresses(group) == [address1, address2]

      # only addresses for that group
      # |> with_geocode()
      _ = insert(:address, group_id: group2.id)
      assert Locations.list_addresses(group) == [address1, address2]
    end

    test "get_address!/1 returns the address with given id" do
      group = insert(:group)
      # |> with_geocode()
      address = insert(:address, group_id: group.id)
      assert Locations.get_address!(address.id) == address
    end

    test "get_address!/1 with a non-existent id throws an error" do
      assert_raise Ecto.NoResultsError,
                   ~r/^expected at least one result but got none in query/,
                   fn ->
                     Locations.get_address!(1312)
                   end
    end

    test "create_address/2 with valid data creates an address" do
      # GeocoderMock |> expect(:geocode_address, 2, fn _address ->
      #   {:ok, params_for(:geocode)}
      # end)

      group = insert(:group)

      # geocode = params_for(:geocode)

      attrs = string_params_for(:address)
      assert {:ok, %Address{} = address} = Locations.create_address(group, attrs)
      assert address.label == attrs["label"]
      assert address.street == attrs["street"]
      assert address.city == attrs["city"]
      assert address.province == attrs["province"]
      assert address.country_code == attrs["country_code"]
      assert address.postal_code == attrs["postal_code"]
      # assert address.geocode.lat == geocode.lat
      # assert address.geocode.lng == geocode.lng
      # assert address.geocode.data == geocode.data
    end

    test "create_address/2 with invalid data returns error changeset" do
      group = insert(:group)

      # is nil
      attrs = string_params_for(:invalid_nil_address)
      assert {:error, %Ecto.Changeset{} = changeset} = Locations.create_address(group, attrs)
      assert 3 == length(changeset.errors)

      # too short
      attrs = string_params_for(:invalid_short_address)
      assert {:error, %Ecto.Changeset{} = changeset} = Locations.create_address(group, attrs)
      assert 3 == length(changeset.errors)

      # too long
      attrs = string_params_for(:invalid_long_address)
      assert {:error, %Ecto.Changeset{} = changeset} = Locations.create_address(group, attrs)
      assert 6 == length(changeset.errors)
    end

    test "update_address/2 with valid data updates the address" do
      # GeocoderMock |> expect(:geocode_address, fn _address ->
      #   {:ok, params_for(:geocode)}
      # end)

      group = insert(:group)
      address = insert(:address, group_id: group.id)
      # geocode = params_for(:geocode)

      # typical
      attrs = params_for(:address)
      assert {:ok, %Address{} = address} = Locations.update_address(address, attrs)
      assert address.label == attrs.label
      assert address.street == attrs.street
      assert address.city == attrs.city
      assert address.province == attrs.province
      assert address.country_code == attrs.country_code
      assert address.postal_code == attrs.postal_code
      # assert address.geocode.lat == geocode.lat
      # assert address.geocode.lng == geocode.lng
      # assert address.geocode.data == geocode.data
    end

    test "update_address/2 with invalid data returns error changeset" do
      group = insert(:group)
      # |> with_geocode()
      address = insert(:address, group_id: group.id)

      # too short
      attrs = params_for(:invalid_short_address)
      assert {:error, %Ecto.Changeset{} = changeset} = Locations.update_address(address, attrs)
      assert 3 == length(changeset.errors)
      assert address == Locations.get_address!(address.id)

      # too long
      attrs = params_for(:invalid_long_address)
      assert {:error, %Ecto.Changeset{} = changeset} = Locations.update_address(address, attrs)
      assert 6 == length(changeset.errors)
      assert address == Locations.get_address!(address.id)
    end

    test "delete_address/1 deletes the address" do
      group = insert(:group)
      address = insert(:address, group_id: group.id)
      assert {:ok, %Address{}} = Locations.delete_address(address)
      assert_raise Ecto.NoResultsError, fn -> Locations.get_address!(address.id) end
    end

    test "change_address/1 returns a address changeset" do
      group = insert(:group)
      address = insert(:address, group_id: group.id)
      assert %Ecto.Changeset{} = Locations.change_address(address)
    end
  end

  # Maps
  # ==============================================================================
  #   describe "maps" do

  #     # Tests
  #     # ----------------------------------------------------------

  #     test "get_map/1 with no controls set returns a map with all addresses included as results" do
  #       group1 = insert(:group)
  #       group2 = insert(:group)

  #       # no addresses
  #       {:ok, map} = Locations.get_map()
  #       assert map.results == []

  #       # 1 address, 1 group
  #       address1 = insert(:address, group: group1) |> Map.put(:project, nil) # |> with_geocode()
  #       {:ok, map} = Locations.get_map()
  #       assert map.results == [address1]

  #       # n addresses, 1 group
  #       address2 = insert(:address, group: group1) |> Map.put(:project, nil) # |> with_geocode()
  #       {:ok, map} = Locations.get_map()
  #       assert map.results == [address1, address2]

  #       # n addresses, n groups
  #       address3 = insert(:address, group: group2) |> Map.put(:project, nil) # |> with_geocode()
  #       {:ok, map} = Locations.get_map()
  #       assert map.results == [address1, address2, address3]

  #       # project addresses are also included
  #       project1 = insert(:project, group: group1)
  #       address4 = project1.address
  #       |> Map.put(:group, nil)
  #       |> Map.put(:project, project1 |> without_assoc(:address))

  #       {:ok, map} = Locations.get_map()
  #       assert map.results == [address1, address2, address3, address4]
  #     end

  #     test "get_map/1 with the group_filter control set returns a map with all addresses of the selected groups" do
  #       group1 = insert(:group)
  #       address1 = insert(:address, group: group1)
  # #      |> with_geocode()
  #       |> Map.put(:project, nil)

  #       group2 = insert(:group)
  #       address2 = insert(:address, group: group2)
  # #      |> with_geocode()
  #       |> Map.put(:project, nil)

  #       group3 = insert(:group)

  #       project1 = insert(:project, group: group2)
  #       address3 = project1.address
  #       |> Map.put(:group, nil)
  #       |> Map.put(:project, project1 |> without_assoc(:address))

  #       # no group selected
  #       {:ok, map} = Locations.get_map(%{group_filter: []})
  #       assert map.results == [address1, address2, address3]

  #       # group1 selected
  #       {:ok, map} = Locations.get_map(%{group_filter: [group1.id]})
  #       assert map.results == [address1]

  #       # group 2 selected- includes project address
  #       {:ok, map} = Locations.get_map(%{group_filter: [group2.id]})
  #       assert map.results == [address2, address3]

  #       # group1 & group2 selected
  #       {:ok, map} = Locations.get_map(%{group_filter: [group1.id, group2.id]})
  #       assert map.results == [address1, address2, address3]

  #       # all groups select
  #       {:ok, map} = Locations.get_map(%{group_filter: [group1.id, group2.id, group3.id]})
  #       assert map.results == [address1, address2, address3]
  #     end

  #     test "change_map/1 returns a map changeset" do
  #       {:ok, map} = Locations.get_map()
  #       assert %Ecto.Changeset{} = Locations.change_map(map)
  #     end

  #   end
end
