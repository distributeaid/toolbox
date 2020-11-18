defmodule Ferry.ProfilesTest do
  use Ferry.DataCase

  import Mox

  alias Ferry.Profiles

  # Groups
  # ==============================================================================
  describe "groups" do
    alias Ferry.Profiles.Group

    test "list_groups/0 returns all groups" do
      # no groups a part from the default distribute aid
      # group
      [%{name: "DistributeAid"}] = Profiles.list_groups()

      # 1 extra group
      insert(:group, %{name: "group1"})
      [_, %{name: "group1"}] = Profiles.list_groups()

      # multiple groups
      insert(:group, %{name: "group2"})
      [_, %{name: "group1"}, %{name: "group2"}] = Profiles.list_groups()
    end

    test "get_group!/1 returns the group with given id" do
      group = insert(:group)
      assert Profiles.get_group!(group.id) == group
    end

    test "get_group!/1 with a non-existent id throws an error" do
      assert_raise Ecto.NoResultsError,
                   ~r/^expected at least one result but got none in query/,
                   fn ->
                     Profiles.get_group!(1312)
                   end
    end

    test "create_group/1 with valid data creates a group" do
      params = params_for(:group)
      assert {:ok, %Group{} = group} = Profiles.create_group(params)
      assert group.name == params.name
      assert group.description == params.description
    end

    test "create_group/1 with invalid data returns error changeset" do
      invalid_params = params_for(:invalid_group)
      assert {:error, %Ecto.Changeset{}} = Profiles.create_group(invalid_params)

      invalid_params = params_for(:invalid_url_group)
      assert {:error, %Ecto.Changeset{} = changeset} = Profiles.create_group(invalid_params)
      assert length(changeset.errors) == 7
    end

    defp with_logo(params, path) do
      Map.put(params, :logo, %{
        __struct__: Plug.Upload,
        path: path,
        filename: Path.basename(path)
      })
    end

    test "update_group/2 with valid data updates the group" do
      group = insert(:group)

      update_params =
        params_for(:group)
        # add a logo upload
        |> with_logo(Path.join(File.cwd!(), "test/fixtures/sample.png"))

      # typical
      assert {:ok, group} = Profiles.update_group(group, update_params)
      assert %Group{} = group
      assert group.name == update_params.name
      assert group.description == update_params.description

      # check that the logo was propertly uploaded
      %{file_name: "sample.png", updated_at: _} = group.logo
      # check that a thumbnail was created too
      stat = File.stat!(Path.join(File.cwd!(), "uploads/groups/#{group.id}/logo/logo_thumb.jpg"))
      assert :regular == stat.type
    end

    test "update_group/2 with invalid data returns error changeset" do
      group = insert(:group)

      invalid_params = params_for(:invalid_group)
      assert {:error, %Ecto.Changeset{}} = Profiles.update_group(group, invalid_params)
      assert group == Profiles.get_group!(group.id)

      invalid_params = params_for(:invalid_url_group)

      assert {:error, %Ecto.Changeset{} = changeset} =
               Profiles.update_group(group, invalid_params)

      assert length(changeset.errors) == 7
      assert group == Profiles.get_group!(group.id)
    end

    test "delete_group/1 deletes the group" do
      group = insert(:group)
      assert {:ok, %Group{}} = Profiles.delete_group(group)
      assert_raise Ecto.NoResultsError, fn -> Profiles.get_group!(group.id) end
    end

    test "change_group/1 returns a group changeset" do
      group = insert(:group)
      assert %Ecto.Changeset{} = Profiles.change_group(group)
    end
  end

  # Projects
  # ==============================================================================
  describe "projects" do
    alias Ferry.Profiles.{Group, Project}

    setup :verify_on_exit!

    # Tests
    # ----------------------------------------------------------

    test "list_projects/0 returns all projects" do
      group1 = insert(:group)
      group2 = insert(:group)

      # no projects
      assert Profiles.list_projects() == []

      # 1 project, 1 group
      project1 =
        insert(:project, %{group: group1})
        |> without_assoc(:group)

      assert Profiles.list_projects() == [project1]

      # multiple projects, 1 group
      project2 =
        insert(:project, %{group: group1})
        |> without_assoc(:group)

      assert Profiles.list_projects() == [project1, project2]

      # multiple project, multiple groups
      project3 =
        insert(:project, %{group: group2})
        |> without_assoc(:group)

      project4 =
        insert(:project, %{group: group2})
        |> without_assoc(:group)

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
      project2 =
        insert(:project, %{group: group1})
        |> without_assoc(:group)

      project3 =
        insert(:project, %{group: group1})
        |> without_assoc(:group)

      assert Profiles.list_projects(group1) == [project2, project3]
    end

    test "get_project!/1 returns the project with given id" do
      project =
        insert(:project)
        |> without_assoc(:group)

      assert Profiles.get_project!(project.id) == project
    end

    test "get_project!/1 with a non-existent id throws an error" do
      assert_raise Ecto.NoResultsError,
                   ~r/^expected at least one result but got none in query/,
                   fn ->
                     Profiles.get_project!(1312)
                   end
    end

    test "create_project/2 with valid data creates a project" do
      group = insert(:group)

      # typical
      attrs = string_params_for(:project, %{group_id: group.id})
      assert {:ok, %Project{} = project} = Profiles.create_project(group, attrs)
      assert project.group_id == group.id
      assert project.name == attrs["name"]
      assert project.description == attrs["description"]

      # min
      attrs = string_params_for(:min_project, %{group_id: group.id})
      assert {:ok, %Project{} = project} = Profiles.create_project(group, attrs)
      assert project.group_id == group.id
      assert project.name == attrs["name"]
      assert project.description == nil
    end

    test "create_project/2 with invalid data returns error changeset" do
      group = insert(:group)
      attrs = params_for(:invalid_project)
      assert {:error, %Ecto.Changeset{}} = Profiles.create_project(group, attrs)
    end

    test "update_project/2 with valid data updates the project" do
      project = insert(:project)

      # typical
      attrs = string_params_for(:project)
      assert {:ok, project} = Profiles.update_project(project, attrs)
      assert %Project{} = project
      assert project.name == attrs["name"]
      assert project.description == attrs["description"]
    end

    test "update_project/2 with invalid data returns error changeset" do
      project =
        insert(:project)
        |> without_assoc(:group)

      attrs = params_for(:invalid_project)
      assert {:error, %Ecto.Changeset{}} = Profiles.update_project(project, attrs)
      assert project == Profiles.get_project!(project.id)
    end

    test "delete_project/1 deletes the project" do
      project = insert(:project)
      assert {:ok, %Project{}} = Profiles.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Profiles.get_project!(project.id) end
    end
  end
end
