defmodule Ferry.ProfilesTest do
  use Ferry.DataCase

  import Mox

  alias Ferry.Profiles

  # Groups
  # ==============================================================================
  describe "groups" do
    alias Ferry.Profiles.Group

    # Data & Helpers
    # ----------------------------------------------------------

    @valid_attrs %{
      typical: %{name: "My Refugee Aid Group", description: "We help newcomers!"},
      min: %{name: "My Other Refugee Aid Group"}
    }

    @update_attrs %{
      typical: %{name: "My Refugee Squat", description: "We house newcomers!"}
    }

    @invalid_attrs %{
      is_nil: %{name: nil},
      too_short: %{name: ""},
      too_long: %{name: "This name is really way too long.  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}
    }

    def group_fixture(attrs \\ %{}) do
      {:ok, group} =
        attrs
        |> Enum.into(@valid_attrs.typical)
        |> Profiles.create_group()

      group
    end

    # Tests
    # ----------------------------------------------------------

     test "list_groups/0 returns all groups" do
      # no groups
      assert Profiles.list_groups() == [],
      "returns an empty list if no groups have been created"

      # 1 group
      group1 = group_fixture()
      assert Profiles.list_groups() == [group1]

      # multiple groups
      group2 = group_fixture(%{name: "A Second Group"})
      assert Profiles.list_groups() == [group1, group2]
    end

    test "get_group!/1 returns the group with given id" do
      group = group_fixture()
      assert Profiles.get_group!(group.id) == group
    end

    test "get_group!/1 with a non-existent id throws an error" do
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
      # is nil
      assert {:error, %Ecto.Changeset{}} = Profiles.create_group(@invalid_attrs.is_nil)

      # too short
      assert {:error, %Ecto.Changeset{}} = Profiles.create_group(@invalid_attrs.too_short)

      # too long
      assert {:error, %Ecto.Changeset{}} = Profiles.create_group(@invalid_attrs.too_long)
    end

    test "update_group/2 with valid data updates the group" do
      group = group_fixture()

      # typical
      assert {:ok, group} = Profiles.update_group(group, @update_attrs.typical)
      assert %Group{} = group
      assert group.name == @update_attrs.typical.name
      assert group.description == @update_attrs.typical.description
    end

    test "update_group/2 with invalid data returns error changeset" do
      group = group_fixture()
      
      # is nil
      assert {:error, %Ecto.Changeset{}} = Profiles.update_group(group, @invalid_attrs.is_nil)
      assert group == Profiles.get_group!(group.id)

      # too short
      assert {:error, %Ecto.Changeset{}} = Profiles.update_group(group, @invalid_attrs.too_short)
      assert group == Profiles.get_group!(group.id)

      #too long
      assert {:error, %Ecto.Changeset{}} = Profiles.update_group(group, @invalid_attrs.too_long)
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


  # Projects
  # ==============================================================================
  describe "projects" do
    alias Ferry.Profiles.{Group, Project}
    alias Ferry.Locations.Geocoder.GeocoderMock

    setup :verify_on_exit!

    # Tests
    # ----------------------------------------------------------

    test "list_projects/0 returns all projects" do
      group1 = insert(:group)
      group2 = insert(:group)

      # no projects
      assert Profiles.list_projects() == []

      # 1 project, 1 group
      project1 = insert(:project, %{group: group1}) |> without_assoc([:address, :geocode])
      assert Profiles.list_projects() == [project1]

      # multiple projects, 1 group
      project2 = insert(:project, %{group: group1}) |> without_assoc([:address, :geocode])
      assert Profiles.list_projects() == [project1, project2]

      # multiple project, multiple groups
      project3 = insert(:project, %{group: group2}) |> without_assoc([:address, :geocode])
      project4 = insert(:project, %{group: group2}) |> without_assoc([:address, :geocode])
      assert Profiles.list_projects() == [project1, project2, project3, project4]
    end

    test "list_projects/1 returns all projects for the specified group" do
      group1 = insert(:group)
      group2 = insert(:group)

      # no projects
      assert Profiles.list_projects(group1) == []

      # no projects for group
      _ = insert(:project, %{group: group2})
      assert Profiles.list_projects(group1) == []

      # multiple projects for group
      project2 = insert(:project, %{group: group1}) |> without_assoc([:address, :geocode]) |> without_assoc(:group)
      project3 = insert(:project, %{group: group1}) |> without_assoc([:address, :geocode]) |> without_assoc(:group)
      assert Profiles.list_projects(group1) == [project2, project3]
    end

    test "get_project!/1 returns the project with given id" do
      project = insert(:project) |> without_assoc([:address, :geocode]) |> without_assoc(:group)
      assert Profiles.get_project!(project.id) == project
    end

    test "get_project!/1 with a non-existent id throws an error" do
      assert_raise Ecto.NoResultsError, ~r/^expected at least one result but got none in query/, fn ->
        Profiles.get_project!(1312)
      end
    end

    test "create_project/2 with valid data creates a project" do
      GeocoderMock |> expect(:geocode_address, 2, fn _address ->
        {:ok, params_for(:geocode)}
      end)

      group = insert(:group)
      geocode = params_for(:geocode)

      # typical
      attrs = string_params_for(:project, %{group_id: group.id})
      assert {:ok, %Project{} = project} = Profiles.create_project(group, attrs)
      assert project.group_id == group.id
      assert project.name == attrs["name"]
      assert project.description == attrs["description"]
      assert project.address.label == attrs["address"]["label"]
      assert project.address.street == attrs["address"]["street"]
      assert project.address.city == attrs["address"]["city"]
      assert project.address.state == attrs["address"]["state"]
      assert project.address.country == attrs["address"]["country"]
      assert project.address.zip_code == attrs["address"]["zip_code"]
      assert project.address.geocode.lat == geocode.lat
      assert project.address.geocode.lng == geocode.lng
      assert project.address.geocode.data == geocode.data

      # min
      attrs = string_params_for(:min_project, %{group_id: group.id})
      assert {:ok, %Project{} = project} = Profiles.create_project(group, attrs)
      assert project.group_id == group.id
      assert project.name == attrs["name"]
      assert project.description == nil
      assert project.address.label == attrs["address"]["label"]
      assert project.address.street == attrs["address"]["street"]
      assert project.address.city == attrs["address"]["city"]
      assert project.address.state == attrs["address"]["state"]
      assert project.address.country == attrs["address"]["country"]
      assert project.address.zip_code == attrs["address"]["zip_code"]
      assert project.address.geocode.lat == geocode.lat
      assert project.address.geocode.lng == geocode.lng
      assert project.address.geocode.data == geocode.data
    end

    test "create_project/2 with invalid data returns error changeset" do
      group = insert(:group)
      attrs = params_for(:invalid_project)
      assert {:error, %Ecto.Changeset{}} = Profiles.create_project(group, attrs)
    end

    test "update_project/2 with valid data updates the project" do
      GeocoderMock |> expect(:geocode_address, fn _address ->
        {:ok, params_for(:geocode)}
      end)

      project = insert(:project)
      geocode = params_for(:geocode)

      # typical
      attrs = string_params_for(:project)
      assert {:ok, project} = Profiles.update_project(project, attrs)
      assert %Project{} = project
      assert project.name == attrs["name"]
      assert project.description == attrs["description"]
      assert project.address.label == attrs["address"]["label"]
      assert project.address.street == attrs["address"]["street"]
      assert project.address.city == attrs["address"]["city"]
      assert project.address.state == attrs["address"]["state"]
      assert project.address.country == attrs["address"]["country"]
      assert project.address.zip_code == attrs["address"]["zip_code"]
      assert project.address.geocode.lat == geocode.lat
      assert project.address.geocode.lng == geocode.lng
      assert project.address.geocode.data == geocode.data
    end

    test "update_project/2 with invalid data returns error changeset" do
      project = insert(:project) |> without_assoc([:address, :geocode]) |> without_assoc(:group)
      attrs = params_for(:invalid_project)
      assert {:error, %Ecto.Changeset{}} = Profiles.update_project(project, attrs)
      assert project == Profiles.get_project!(project.id)
    end

    test "delete_project/1 deletes the project" do
      project = insert(:project)
      assert {:ok, %Project{}} = Profiles.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Profiles.get_project!(project.id) end
    end

    test "change_project/1 returns a project changeset" do
      project = insert(:project)
      assert %Ecto.Changeset{} = Profiles.change_project(project)
    end
  end
end
