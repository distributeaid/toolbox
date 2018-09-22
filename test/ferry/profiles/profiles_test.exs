defmodule Ferry.ProfilesTest do
  use Ferry.DataCase

  alias Ferry.Profiles

  describe "groups" do
    alias Ferry.Profiles.Group

    @valid_attrs %{
      typical: %{name: "My Refugee Aid Group", description: "We help newcomers!"},
      min: %{name: "My Refugee Aid Group"}
    }

    @update_attrs %{
      typical: %{name: "My Refugee Squat", description: "We house newcomers!"}
    }

    @invalid_attrs %{
      name_nil: %{name: nil},
      name_too_short: %{name: ""},
      name_too_long: %{name: "This name is really way too long.  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}
    }

    def group_fixture(attrs \\ %{}) do
      {:ok, group} =
        attrs
        |> Enum.into(@valid_attrs.typical)
        |> Profiles.create_group()

      group
    end

    test "list_groups/0 returns all groups" do
      # no groups
      assert Profiles.list_groups() == [],
      "returns an empty list if no groups have been created"

      # 1 group
      group1 = group_fixture()
      assert Profiles.list_groups() == [group1]

      # n groups
      group2 = group_fixture()
      assert Profiles.list_groups() == [group1, group2]
    end

    test "get_group!/1 returns the group with given id" do
      group = group_fixture()
      assert Profiles.get_group!(group.id) == group
    end

    test "get_group!/1 with a non-existant id throws an error" do
      assert_raise Ecto.NoResultsError, ~r/^expected at least one result but got none in query/, fn ->
        Profiles.get_group!(1312)
      end
    end

    test "create_group/1 with valid data creates a group" do
      # typical
      assert {:ok, %Group{} = group} = Profiles.create_group(@valid_attrs.typical)
      assert group.name == @valid_attrs.typical.name
      assert group.description == @valid_attrs.typical.description

      # min
      assert {:ok, %Group{} = group} = Profiles.create_group(@valid_attrs.min)
      assert group.name == @valid_attrs.min.name
      assert group.description == nil
    end

    test "create_group/1 with invalid data returns error changeset" do
      # name_nil
      assert {:error, %Ecto.Changeset{}} = Profiles.create_group(@invalid_attrs.name_nil)

      # name_too_short
      assert {:error, %Ecto.Changeset{}} = Profiles.create_group(@invalid_attrs.name_too_short)

      # name_too_long
      assert {:error, %Ecto.Changeset{}} = Profiles.create_group(@invalid_attrs.name_too_long)
    end

    test "update_group/2 with valid data updates the group" do
      # typical
      group = group_fixture()
      assert {:ok, group} = Profiles.update_group(group, @update_attrs.typical)
      assert %Group{} = group
      assert group.name == @update_attrs.typical.name
      assert group.description == @update_attrs.typical.description
    end

    test "update_group/2 with invalid data returns error changeset" do
      # name_nil
      group = group_fixture()
      assert {:error, %Ecto.Changeset{}} = Profiles.update_group(group, @invalid_attrs.name_nil)
      assert group == Profiles.get_group!(group.id)

      # name_too_short
      group = group_fixture()
      assert {:error, %Ecto.Changeset{}} = Profiles.update_group(group, @invalid_attrs.name_too_short)
      assert group == Profiles.get_group!(group.id)

      #name_too_long
      group = group_fixture()
      assert {:error, %Ecto.Changeset{}} = Profiles.update_group(group, @invalid_attrs.name_too_long)
      assert group == Profiles.get_group!(group.id)
    end

    test "delete_group/1 deletes the group" do
      group = group_fixture()
      assert {:ok, %Group{}} = Profiles.delete_group(group)
      assert_raise Ecto.NoResultsError, fn -> Profiles.get_group!(group.id) end
    end

    test "change_group/1 returns a group changeset" do
      group = group_fixture()
      assert %Ecto.Changeset{} = Profiles.change_group(group)
    end
  end
end
