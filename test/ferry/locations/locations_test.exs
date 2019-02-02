defmodule Ferry.LocationsTest do
  use Ferry.DataCase

  alias Ferry.Locations

  # Addresses
  # ==============================================================================
  describe "addresses" do
    alias Ferry.Profiles
    alias Ferry.Locations.Address

    # Data & Helpers
    # ----------------------------------------------------------

    @valid_attrs %{
      typical: %{label: "HQ", street: "123 Downtown Street", city: "Lund", state: "Skåne", country: "Sweden", zip_code: "222 23"},
      min: %{label: "Warehouse", city: "Copenhagen", country: "Denmark"}
    }

    @update_attrs %{
      typical: %{label: "New HQ", street: "123 Office Street", city: "Berlin", state: "Brandenburg", country: "Germany", zip_code: "161-AFA"}
    }

    @invalid_attrs %{
      is_nil: %{label: nil, city: nil, country: nil},
      too_short: %{label: "", city: "", country: ""},
      too_long: %{
        label: "This is really way too long. xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        street: "This is really way too long. xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        city: "This is really way too long. xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        state: "This is really way too long. xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        country: "This is really way too long. xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        zip_code: "This is really way too long. xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      }
    }

    def address_fixture(owner, attrs \\ %{}) do
      attrs = Enum.into(attrs, @valid_attrs.typical)
      {:ok, address} = Locations.create_address(owner, attrs)

      address
    end

    def group_and_project_fixtures(n \\ 1) do
      n = to_string(n)
      {:ok, group} = Profiles.create_group(%{name: "Food Clothing and Resistance Collective " <> n})
      {:ok, project} = Profiles.create_project(group, %{name: "Feed The People " <> n})

      {group, project}
    end

    # Tests
    # ----------------------------------------------------------
    # NOTE: Functions like create_address/2 which are required to distinguish
    #       between address owners (groups or projects) must test with both.
    #       Other functions like list_addresses/0 may only test with one.

    test "list_addresses/1 returns all addresses for a group" do
      {group, project} = group_and_project_fixtures(1)
      {group2, _} = group_and_project_fixtures(2)

      # no addresses
      assert Locations.list_addresses(group) == []

      # 1 address
      address1 = address_fixture(group)
      assert Locations.list_addresses(group) == [address1]

      # n addresses
      address2 = address_fixture(group)
      assert Locations.list_addresses(group) == [address1, address2]

      # only addresses for that group
      _ = address_fixture(group2)
      _ = address_fixture(project)
      assert Locations.list_addresses(group) == [address1, address2]
    end

    test "list_addresses/1 returns all addresses for a project" do
      {group, project} = group_and_project_fixtures(1)
      {_, project2} = group_and_project_fixtures(2)

      # no addresses
      assert Locations.list_addresses(project) == []

      # 1 address
      address1 = address_fixture(project)
      assert Locations.list_addresses(project) == [address1]

      # n addresses
      address2 = address_fixture(project)
      assert Locations.list_addresses(project) == [address1, address2]

      # only addresses for that group
      _ = address_fixture(group)
      _ = address_fixture(project2)
      assert Locations.list_addresses(project) == [address1, address2]
    end

    @tag skip: "Stubbed Function. Don't fail the build. Remove this tag & fill in test when the method is implemented."
    test "list_countries/0 returns all countries"

    @tag skip: "Stubbed Function. Don't fail the build. Remove this tag & fill in test when the method is implemented."
    test "list_cities/0 returns tuples for all city / country pairs"

    @tag skip: "Stubbed Function. Don't fail the build. Remove this tag & fill in test when the method is implemented."
    test "list_cities/1 returns tuples for all cities in the specified country"

    test "get_address!/1 returns the address with given id" do
      {group, _} = group_and_project_fixtures()
      address = address_fixture(group)
      assert Locations.get_address!(address.id) == address
    end

    test "get_address!/1 with a non-existent id throws an error" do
      assert_raise Ecto.NoResultsError, ~r/^expected at least one result but got none in query/, fn ->
        Locations.get_address!(1312)
      end
    end

    test "create_address/2 with valid data creates a address" do
      {group, project} = group_and_project_fixtures()

      # typical
      assert {:ok, %Address{} = address} = Locations.create_address(group, @valid_attrs.typical)
      assert address.label == @valid_attrs.typical.label
      assert address.street == @valid_attrs.typical.street
      assert address.city == @valid_attrs.typical.city
      assert address.state == @valid_attrs.typical.state
      assert address.country == @valid_attrs.typical.country
      assert address.zip_code == @valid_attrs.typical.zip_code

      assert {:ok, %Address{} = address} = Locations.create_address(project, @valid_attrs.typical)
      assert address.label == @valid_attrs.typical.label
      assert address.street == @valid_attrs.typical.street
      assert address.city == @valid_attrs.typical.city
      assert address.state == @valid_attrs.typical.state
      assert address.country == @valid_attrs.typical.country
      assert address.zip_code == @valid_attrs.typical.zip_code

      # min
      assert {:ok, %Address{} = address} = Locations.create_address(group, @valid_attrs.min)
      assert address.label == @valid_attrs.min.label
      assert address.street == nil
      assert address.city == @valid_attrs.min.city
      assert address.state == nil
      assert address.country == @valid_attrs.min.country
      assert address.zip_code == nil

      assert {:ok, %Address{} = address} = Locations.create_address(project, @valid_attrs.min)
      assert address.label == @valid_attrs.min.label
      assert address.street == nil
      assert address.city == @valid_attrs.min.city
      assert address.state == nil
      assert address.country == @valid_attrs.min.country
      assert address.zip_code == nil
    end

    test "create_address/2 with invalid data returns error changeset" do
      {group, project} = group_and_project_fixtures()

      # is nil
      assert {:error, changeset = %Ecto.Changeset{}} = Locations.create_address(group, @invalid_attrs.is_nil)
      assert 3 == changeset.errors |> length
      assert {:error, changeset = %Ecto.Changeset{}} = Locations.create_address(project, @invalid_attrs.is_nil)
      assert 3 == changeset.errors |> length

      # too short
      assert {:error, %Ecto.Changeset{}} = Locations.create_address(group, @invalid_attrs.too_short)
      assert {:error, %Ecto.Changeset{}} = Locations.create_address(project, @invalid_attrs.too_short)

      # too long
      assert {:error, %Ecto.Changeset{}} = Locations.create_address(group, @invalid_attrs.too_long)
      assert {:error, %Ecto.Changeset{}} = Locations.create_address(project, @invalid_attrs.too_long)
    end

    @tag skip: "TODO - Don't fail CI builds.  Remove this tag to force a failure if related problems occur."
    test "the database's has_exactly_one_owner check constraint throws and error if an address has no or multiple owners"

    test "update_address/2 with valid data updates the address" do
      {group, _} = group_and_project_fixtures()
      address = address_fixture(group)

      # typical
      assert {:ok, address} = Locations.update_address(address, @update_attrs.typical)
      assert %Address{} = address
      assert address.label == @update_attrs.typical.label
      assert address.street == @update_attrs.typical.street
      assert address.city == @update_attrs.typical.city
      assert address.state == @update_attrs.typical.state
      assert address.country == @update_attrs.typical.country
      assert address.zip_code == @update_attrs.typical.zip_code
    end

    test "update_address/2 with invalid data returns error changeset" do
      {group, _} = group_and_project_fixtures()
      address = address_fixture(group)

      # is nil
      assert {:error, changeset = %Ecto.Changeset{}} = Locations.update_address(address, @invalid_attrs.is_nil)
      assert 3 == changeset.errors |> length
      assert address == Locations.get_address!(address.id)

      # too short
      assert {:error, %Ecto.Changeset{}} = Locations.update_address(address, @invalid_attrs.too_short)
      assert address == Locations.get_address!(address.id)

      # too long
      assert {:error, %Ecto.Changeset{}} = Locations.update_address(address, @invalid_attrs.too_long)
      assert address == Locations.get_address!(address.id)
    end

    test "delete_address/1 deletes the address" do
      {group, _} = group_and_project_fixtures()
      address = address_fixture(group)
      assert {:ok, %Address{}} = Locations.delete_address(address)
      assert_raise Ecto.NoResultsError, fn -> Locations.get_address!(address.id) end
    end

    @tag skip: "TODO - Don't fail CI builds.  Remove this tag to force a failure if related problems occur."
    test "the database's on_delete:delete_all setting deletes related addresses when a group is deleted"

    @tag skip: "TODO - Don't fail CI builds.  Remove this tag to force a failure if related problems occur."
    test "the database's on_delete:delete_all setting deletes related addresses when a project is deleted"

    test "change_address/1 returns a address changeset" do
      {group, _} = group_and_project_fixtures()
      address = address_fixture(group)
      assert %Ecto.Changeset{} = Locations.change_address(address)
    end
  end


  # Maps
  # ==============================================================================
  describe "maps" do
    alias Ferry.Locations.Map
    alias Ferry.Profiles.Group

    # Data & Helpers
    # ----------------------------------------------------------

    def map_result_fixture(%Group{} = group, attrs \\ %{}) do
      address = insert(:address, group: group)
      %{address | project: nil}
    end

    # TODO: map_result_fixture w/ a project owning the address

    # Tests
    # ----------------------------------------------------------

    @tag skip: "TODO - Don't fail CI builds.  Remove this tag to force a failure if related problems occur."
    test "get_map/1 lists all groups (in alphabetical order) in the `group_filter_labels` field"

    test "get_map/1 with no controls set returns a map with all addresses included as results" do
      group = insert(:group)

      # no addresses
      {:ok, map} = Locations.get_map()
      assert map.results == []

      # 1 address
      address1 = map_result_fixture(group)
      {:ok, map} = Locations.get_map()
      assert map.results == [address1]

      # n addresses
      address2 = map_result_fixture(group)
      {:ok, map} = Locations.get_map()
      assert map.results == [address1, address2]
    end

    test "get_map/2 with the group_filter control set returns a map with all addresses of the selected groups" do
      group1 = insert(:group)
      group2 = insert(:group)
      group3 = insert(:group)

      address1 = map_result_fixture(group1)
      address2 = map_result_fixture(group2)
      # group3 has no addresses

      # no group selected
      {:ok, map} = Locations.get_map(%{group_filter: []})
      assert map.results == [address1, address2]

      # group1 selected
      {:ok, map} = Locations.get_map(%{group_filter: [group1.id]})
      assert map.results == [address1]

      # group1 & group2 selected
      {:ok, map} = Locations.get_map(%{group_filter: [group1.id, group2.id]})
      assert map.results == [address1, address2]

      # all groups select
      {:ok, map} = Locations.get_map(%{group_filter: [group1.id, group2.id, group3.id]})
      assert map.results == [address1, address2]
    end

    test "change_map/1 returns a map changeset" do
      {:ok, map} = Locations.get_map()
      assert %Ecto.Changeset{} = Locations.change_map(map)
    end

  end
end
