defmodule Ferry.LocationsTest do
  use Ferry.DataCase

  import Mox

  alias Ferry.Locations

  # Addresses
  # ==============================================================================
  describe "addresses" do
    alias Ferry.Profiles.Group
    alias Ferry.Locations.Address
    alias Ferry.Locations.Geocoder.GeocoderMock

    setup :verify_on_exit!

    # Tests
    # ----------------------------------------------------------

    test "list_addresses/1 returns all addresses for a group" do
      group = insert(:group)
      group2 = insert(:group)

      # no addresses
      assert Locations.list_addresses(group) == []

      # 1 address
      address1 = insert(:address, group_id: group.id) |> with_geocode()
      assert Locations.list_addresses(group) == [address1]

      # n addresses
      address2 = insert(:address, group_id: group.id) |> with_geocode()
      assert Locations.list_addresses(group) == [address1, address2]

      # only addresses for that group
      _ = insert(:address, group_id: group2.id) |> with_geocode()
      assert Locations.list_addresses(group) == [address1, address2]
    end

    @tag skip: "Stubbed Function. Don't fail the build. Remove this tag & fill in test when the method is implemented."
    test "list_countries/0 returns all countries"

    @tag skip: "Stubbed Function. Don't fail the build. Remove this tag & fill in test when the method is implemented."
    test "list_cities/0 returns tuples for all city / country pairs"

    @tag skip: "Stubbed Function. Don't fail the build. Remove this tag & fill in test when the method is implemented."
    test "list_cities/1 returns tuples for all cities in the specified country"

    test "get_address!/1 returns the address with given id" do
      group = insert(:group)
      address = insert(:address, group_id: group.id) |> with_geocode()
      assert Locations.get_address!(address.id) == address
    end

    test "get_address!/1 with a non-existent id throws an error" do
      assert_raise Ecto.NoResultsError, ~r/^expected at least one result but got none in query/, fn ->
        Locations.get_address!(1312)
      end
    end

    test "create_address/2 with valid data creates an address" do
      GeocoderMock |> expect(:geocode_address, 2, fn _address ->
        {:ok, params_for(:geocode)}
      end)

      group = insert(:group)
      geocode = params_for(:geocode)

      attrs = string_params_for(:address)
      assert {:ok, %Address{} = address} = Locations.create_address(group, attrs)
      assert address.label == attrs["label"]
      assert address.street == attrs["street"]
      assert address.city == attrs["city"]
      assert address.state == attrs["state"]
      assert address.country == attrs["country"]
      assert address.zip_code == attrs["zip_code"]
      assert address.geocode.lat == geocode.lat
      assert address.geocode.lng == geocode.lng
      assert address.geocode.data == geocode.data

      # min
      attrs = string_params_for(:min_address)
      assert {:ok, %Address{} = address} = Locations.create_address(group, attrs)
      assert address.label == attrs["label"]
      assert address.street == nil
      assert address.city == attrs["city"]
      assert address.state == nil
      assert address.country == attrs["country"]
      assert address.zip_code == nil
      assert address.geocode.lat == geocode.lat
      assert address.geocode.lng == geocode.lng
      assert address.geocode.data == geocode.data
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

    @tag skip: "TODO - Don't fail CI builds.  Remove this tag to force a failure if related problems occur."
    test "the database's has_exactly_one_owner check constraint throws and error if an address has no or multiple owners"

    test "update_address/2 with valid data updates the address" do
      GeocoderMock |> expect(:geocode_address, fn _address ->
        {:ok, params_for(:geocode)}
      end)

      group = insert(:group)
      address = insert(:address, group_id: group.id)
      geocode = params_for(:geocode)

      # typical
      attrs = params_for(:address)
      assert {:ok, %Address{} = address} = Locations.update_address(address, attrs)
      assert address.label == attrs.label
      assert address.street == attrs.street
      assert address.city == attrs.city
      assert address.state == attrs.state
      assert address.country == attrs.country
      assert address.zip_code == attrs.zip_code
      assert address.geocode.lat == geocode.lat
      assert address.geocode.lng == geocode.lng
      assert address.geocode.data == geocode.data
    end

    test "update_address/2 with invalid data returns error changeset" do
      group = insert(:group)
      address = insert(:address, group_id: group.id) |> with_geocode()

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

    @tag skip: "TODO - Don't fail CI builds.  Remove this tag to force a failure if related problems occur."
    test "the database's on_delete:delete_all setting deletes related addresses when a group is deleted"

    test "change_address/1 returns a address changeset" do
      group = insert(:group)
      address = insert(:address, group_id: group.id)
      assert %Ecto.Changeset{} = Locations.change_address(address)
    end
  end


  # Maps
  # ==============================================================================
  describe "maps" do
#    alias Ferry.Locations.Map
    alias Ferry.Profiles.Group

    # Tests
    # ----------------------------------------------------------

    @tag skip: "TODO - Don't fail CI builds.  Remove this tag to force a failure if related problems occur."
    test "get_map/1 lists all groups (in alphabetical order) in the `group_filter_labels` field"

    test "get_map/1 with no controls set returns a map with all addresses included as results" do
      group1 = insert(:group)
      group2 = insert(:group)

      # no addresses
      {:ok, map} = Locations.get_map()
      assert map.results == []

      # 1 address, 1 group
      address1 = insert(:address, group: group1) |> with_geocode() |> Map.put(:project, nil)
      {:ok, map} = Locations.get_map()
      assert map.results == [address1]

      # n addresses, 1 group
      address2 = insert(:address, group: group1) |> with_geocode() |> Map.put(:project, nil)
      {:ok, map} = Locations.get_map()
      assert map.results == [address1, address2]

      # n addresses, n groups
      address3 = insert(:address, group: group2) |> with_geocode() |> Map.put(:project, nil)
      {:ok, map} = Locations.get_map()
      assert map.results == [address1, address2, address3]

      # project addresses are also included
      project1 = insert(:project, group: group1)
      address4 = project1.address
      |> Map.put(:group, nil)
      |> Map.put(:project, project1 |> without_assoc(:address))

      {:ok, map} = Locations.get_map()
      assert map.results == [address1, address2, address3, address4]
    end

    test "get_map/1 with the group_filter control set returns a map with all addresses of the selected groups" do
      group1 = insert(:group)
      address1 = insert(:address, group: group1)
      |> with_geocode()
      |> Map.put(:project, nil)

      group2 = insert(:group)
      address2 = insert(:address, group: group2)
      |> with_geocode()
      |> Map.put(:project, nil)

      group3 = insert(:group)

      project1 = insert(:project, group: group2)
      address3 = project1.address
      |> Map.put(:group, nil)
      |> Map.put(:project, project1 |> without_assoc(:address))

      # no group selected
      {:ok, map} = Locations.get_map(%{group_filter: []})
      assert map.results == [address1, address2, address3]

      # group1 selected
      {:ok, map} = Locations.get_map(%{group_filter: [group1.id]})
      assert map.results == [address1]

      # group 2 selected- includes project address
      {:ok, map} = Locations.get_map(%{group_filter: [group2.id]})
      assert map.results == [address2, address3]

      # group1 & group2 selected
      {:ok, map} = Locations.get_map(%{group_filter: [group1.id, group2.id]})
      assert map.results == [address1, address2, address3]

      # all groups select
      {:ok, map} = Locations.get_map(%{group_filter: [group1.id, group2.id, group3.id]})
      assert map.results == [address1, address2, address3]
    end

    test "change_map/1 returns a map changeset" do
      {:ok, map} = Locations.get_map()
      assert %Ecto.Changeset{} = Locations.change_map(map)
    end

  end
end
