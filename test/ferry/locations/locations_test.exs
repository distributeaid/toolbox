defmodule Ferry.LocationsTest do
  use Ferry.DataCase

  alias Ferry.Locations

  # Addresses
  # ==============================================================================
  describe "addresses" do
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

    # TODO: Should really be testing these individually so that they don't hide each other.
    #   ex: nil label isn't caught but the whole invalid test succeeds because nil city/country is caught
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

    def address_fixture(attrs \\ %{}) do
      {:ok, address} =
        attrs
        |> Enum.into(@valid_attrs.typical)
        |> Locations.create_address()

      address
    end

    # Tests
    # ----------------------------------------------------------

    test "list_addresses/0 returns all addresses" do
      # no addresses
      assert Locations.list_addresses() == []

      # 1 address
      address = address_fixture()
      assert Locations.list_addresses() == [address]

      # n addresses
      address2 = address_fixture()
      assert Locations.list_addresses() == [address, address2]
    end

    test "list_countries/0 returns all countries"

    test "list_cities/0 returns tuples for all city / country pairs"

    test "list_cities/1 returns tuples for all cities in the specified country"

    test "get_address!/1 returns the address with given id" do
      address = address_fixture()
      assert Locations.get_address!(address.id) == address
    end

    test "get_address!/1 with a non-existent id throws an error" do
      assert_raise Ecto.NoResultsError, ~r/^expected at least one result but got none in query/, fn ->
        Locations.get_address!(1312)
      end
    end

    test "create_address/1 with valid data creates a address" do
      # typical
      assert {:ok, %Address{} = address} = Locations.create_address(@valid_attrs.typical)
      assert address.label == @valid_attrs.typical.label
      assert address.street == @valid_attrs.typical.street
      assert address.city == @valid_attrs.typical.city
      assert address.state == @valid_attrs.typical.state
      assert address.country == @valid_attrs.typical.country
      assert address.zip_code == @valid_attrs.typical.zip_code

      # min
      assert {:ok, %Address{} = address} = Locations.create_address(@valid_attrs.min)
      assert address.label == @valid_attrs.min.label
      assert address.street == nil
      assert address.city == @valid_attrs.min.city
      assert address.state == nil
      assert address.country == @valid_attrs.min.country
      assert address.zip_code == nil
    end

    test "create_address/1 with invalid data returns error changeset" do
      # is nil
      assert {:error, %Ecto.Changeset{}} = Locations.create_address(@invalid_attrs.is_nil)

      # too short
      assert {:error, %Ecto.Changeset{}} = Locations.create_address(@invalid_attrs.too_short)

      # too long
      assert {:error, %Ecto.Changeset{}} = Locations.create_address(@invalid_attrs.too_long)
    end

    test "update_address/2 with valid data updates the address" do
      # typical
      address = address_fixture()
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
      # is nil
      address = address_fixture()
      assert {:error, %Ecto.Changeset{}} = Locations.update_address(address, @invalid_attrs.is_nil)
      assert address == Locations.get_address!(address.id)

      # too short
      address = address_fixture()
      assert {:error, %Ecto.Changeset{}} = Locations.update_address(address, @invalid_attrs.too_short)
      assert address == Locations.get_address!(address.id)

      # too long
      address = address_fixture()
      assert {:error, %Ecto.Changeset{}} = Locations.update_address(address, @invalid_attrs.too_long)
      assert address == Locations.get_address!(address.id)
    end

    test "delete_address/1 deletes the address" do
      address = address_fixture()
      assert {:ok, %Address{}} = Locations.delete_address(address)
      assert_raise Ecto.NoResultsError, fn -> Locations.get_address!(address.id) end
    end

    test "change_address/1 returns a address changeset" do
      address = address_fixture()
      assert %Ecto.Changeset{} = Locations.change_address(address)
    end
  end
end
