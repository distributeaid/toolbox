defmodule Ferry.ProfilesTest do
  use Ferry.DataCase

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

    # Data & Helpers
    # ----------------------------------------------------------

    @valid_attrs %{
      typical: %{name: "My Warehouse", description: "We distribute to newcomers!"},
      min: %{name: "My Other Warehouse"}
    }

    @update_attrs %{
      typical: %{name: "My Free Store", description: "We cloth newcomers!"}
    }

    @invalid_attrs %{
      is_nil: %{name: nil},
      too_short: %{name: ""},
      too_long: %{name: "This name is really way too long.  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}
    }

    def project_fixture(%Group{} = group, attrs \\ %{}) do
      attrs = Enum.into(attrs, @valid_attrs.typical)
      {:ok, project} = Profiles.create_project(group, attrs)

      project
    end

    # Tests
    # ----------------------------------------------------------

    test "list_projects/0 returns all projects" do
      group1 = group_fixture()
      group2 = group_fixture(%{name: "A Second Group"})

      # no projects
      assert Profiles.list_projects() == [],
      "returns an empty list if no projects have been created"

      # 1 project, 1 group
      project1 = project_fixture(group1)
      assert Profiles.list_projects() == [project1]

      # multiple projects, 1 group
      project2 = project_fixture(group1, %{name: "A Second Project"})
      assert Profiles.list_projects() == [project1, project2]

      # multiple project, multiple groups
      project3 = project_fixture(group2, %{name: "A Third Project"})
      project4 = project_fixture(group2, %{name: "A Fourth Project"})
      assert Profiles.list_projects() == [project1, project2, project3, project4]
    end

    test "list_projects/1 returns all projects for the specified group" do
      group1 = group_fixture()
      group2 = group_fixture(%{name: "A Second Group"})

      # no projects
      assert Profiles.list_projects(group1) == [],
      "returns an empty list if no projects have been created"

      # no projects for group
      _ = project_fixture(group2)
      assert Profiles.list_projects(group1) == [],
      "returns an empty list if no projects have been created by the group"

      # multiple projects for group
      project2 = project_fixture(group1, %{name: "A Second Project"})
      project3 = project_fixture(group1, %{name: "A Third Project"})
      assert Profiles.list_projects(group1) == [project2, project3]
    end

    test "get_project!/1 returns the project with given id" do
      group = group_fixture()
      project = project_fixture(group)
      assert Profiles.get_project!(project.id) == project
    end

    test "get_project!/1 with a non-existent id throws an error" do
      assert_raise Ecto.NoResultsError, ~r/^expected at least one result but got none in query/, fn ->
        Profiles.get_project!(1312)
      end
    end

    test "create_project/2 with valid data creates a project" do
      group = group_fixture()

      # typical
      assert {:ok, %Project{} = project} = Profiles.create_project(group, @valid_attrs.typical)
      assert project.name == @valid_attrs.typical.name
      assert project.description == @valid_attrs.typical.description
      assert project.group_id == group.id

      # min
      assert {:ok, %Project{} = project} = Profiles.create_project(group, @valid_attrs.min)
      assert project.name == @valid_attrs.min.name
      assert project.description == nil
      assert project.group_id == group.id
    end

    test "create_project/2 with invalid data returns error changeset" do
      group = group_fixture()

      # is nil
      assert {:error, %Ecto.Changeset{}} = Profiles.create_project(group, @invalid_attrs.is_nil)

      # too short
      assert {:error, %Ecto.Changeset{}} = Profiles.create_project(group, @invalid_attrs.too_short)

      # too long
      assert {:error, %Ecto.Changeset{}} = Profiles.create_project(group, @invalid_attrs.too_long)
    end

    test "update_project/2 with valid data updates the project" do
      group = group_fixture()
      project = project_fixture(group)

      # typical
      assert {:ok, project} = Profiles.update_project(project, @update_attrs.typical)
      assert %Project{} = project
      assert project.name == @update_attrs.typical.name
      assert project.description == @update_attrs.typical.description
    end

    test "transfer_project/2 with valid data transfers the project to another group"

    test "update_project/2 with invalid data returns error changeset" do
      group = group_fixture()
      project = project_fixture(group)

      # is nil
      assert {:error, %Ecto.Changeset{}} = Profiles.update_project(project, @invalid_attrs.is_nil)
      assert project == Profiles.get_project!(project.id)

      # too short
      assert {:error, %Ecto.Changeset{}} = Profiles.update_project(project, @invalid_attrs.too_short)
      assert project == Profiles.get_project!(project.id)

      # too long
      assert {:error, %Ecto.Changeset{}} = Profiles.update_project(project, @invalid_attrs.too_long)
      assert project == Profiles.get_project!(project.id)
    end

    test "delete_project/1 deletes the project" do
      group = group_fixture()
      project = project_fixture(group)
      assert {:ok, %Project{}} = Profiles.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Profiles.get_project!(project.id) end
    end

    test "the database's on_delete:delete_all setting deletes related projects when a group is deleted"

    test "change_project/1 returns a project changeset" do
      group = group_fixture()
      project = project_fixture(group)
      assert %Ecto.Changeset{} = Profiles.change_project(project)
    end
  end
end
