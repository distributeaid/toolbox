defmodule Ferry.LinksTest do
  use Ferry.DataCase

  alias Ferry.Links

  # Links
  # ==============================================================================
  describe "links" do
    alias Ferry.Profiles
    alias Ferry.CRM
    alias Ferry.Links.Link

    # Data & Helpers
    # ----------------------------------------------------------

    @valid_attrs %{
      typical: %{category: "Website", label: "Homepage", url: "https://distributeaid.org/"},
      min: %{url: "https://movementontheground.org"}
    }

    @update_attrs %{
      typical: %{category: "Donations", label: "Our Patreon", url: "https://patreon.org/distributeaid"}
    }

    @invalid_attrs %{
      is_nil: %{url: nil},
      bad_format: %{url: "there_is_no_dot"},
      too_short: %{url: "h.i"},
      too_long: %{
        category: "This is really way too long. xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        label: "This is really way too long. xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        url: "this-does-not-have-a-length-limit.org"
      }
    }

    def link_fixture(owner, attrs \\ %{}) do
      attrs = Enum.into(attrs, @valid_attrs.typical)
      {:ok, link} = Links.create_link(owner, attrs)

      link
    end

    def owner_fixtures(n \\ 1) do
      n = Integer.to_string(n)
      {:ok, group} = Profiles.create_group(%{name: "Johnny Panic " <> n})
      {:ok, project} = Profiles.create_project(group, %{name: "Voidspit " <> n})
      {:ok, contact} = CRM.create_contact(project)

      {group, project, contact}
    end

    # Tests
    # ----------------------------------------------------------
    # NOTE: Functions like create_contact/2 which are required to distinguish
    #       between contact owners (groups, projects, or contacts) must test
    #       with both. Other functions like list_contacts/0 may only test with
    #       one.

    test "list_links/1 returns all links for a group" do
      {group, project, contact} = owner_fixtures(1)
      {group2, _, _} = owner_fixtures(2)

      # 0 links
      assert Links.list_links(group) == []

      # 1 link
      link1 = link_fixture(group)
      assert Links.list_links(group) == [link1]

      # n links
      link2 = link_fixture(group)
      assert Links.list_links(group) == [link1, link2]

      # only links for that group
      _ = link_fixture(group2)
      _ = link_fixture(project)
      _ = link_fixture(contact)
      assert Links.list_links(group) == [link1, link2]
    end

    test "list_links/1 returns all links for a project" do
      {group, project, contact} = owner_fixtures(1)
      {_, project2, _} = owner_fixtures(2)

      # 0 links
      assert Links.list_links(project) == []

      # 1 link
      link1 = link_fixture(project)
      assert Links.list_links(project) == [link1]

      # n links
      link2 = link_fixture(project)
      assert Links.list_links(project) == [link1, link2]

      # only links for that project
      _ = link_fixture(group)
      _ = link_fixture(project2)
      _ = link_fixture(contact)
      assert Links.list_links(project) == [link1, link2]
    end

    test "list_links/1 returns all links for a contact" do
      {group, project, contact} = owner_fixtures(1)
      {_, _, contact2} = owner_fixtures(2)

      # 0 links
      assert Links.list_links(contact) == []

      # 1 link
      link1 = link_fixture(contact)
      assert Links.list_links(contact) == [link1]

      # n links
      link2 = link_fixture(contact)
      assert Links.list_links(contact) == [link1, link2]

      # only links for that contact
      _ = link_fixture(group)
      _ = link_fixture(project)
      _ = link_fixture(contact2)
      assert Links.list_links(contact) == [link1, link2]
    end

    test "get_link!/1 returns the link with given id" do
      {group, _, _} = owner_fixtures()
      link = link_fixture(group)
      assert Links.get_link!(link.id) == link
    end

    test "get_link!/1 with a non-existent id throws and error" do
      assert_raise Ecto.NoResultsError, ~r/^expected at least one result but got none in query/, fn ->
        CRM.get_contact!(1312)
      end
    end

    test "create_link/2 with valid data creates a link for a group" do
      {group, _, _} = owner_fixtures()

      # typical
      assert {:ok, %Link{} = link} = Links.create_link(group, @valid_attrs.typical)
      assert link.category == @valid_attrs.typical.category
      assert link.label == @valid_attrs.typical.label
      assert link.url == @valid_attrs.typical.url

      #min
      assert {:ok, %Link{} = link} = Links.create_link(group, @valid_attrs.min)
      assert link.category == nil
      assert link.label == nil
      assert link.url == @valid_attrs.min.url
    end

    test "create_link/2 with valid data creates a link for a project" do
      {_, project, _} = owner_fixtures()

      # typical
      assert {:ok, %Link{} = link} = Links.create_link(project, @valid_attrs.typical)
      assert link.category == @valid_attrs.typical.category
      assert link.label == @valid_attrs.typical.label
      assert link.url == @valid_attrs.typical.url

      #min
      assert {:ok, %Link{} = link} = Links.create_link(project, @valid_attrs.min)
      assert link.category == nil
      assert link.label == nil
      assert link.url == @valid_attrs.min.url
    end

    test "create_link/2 with valid data creates a link for a contact" do
      {_, _, contact} = owner_fixtures()

      # typical
      assert {:ok, %Link{} = link} = Links.create_link(contact, @valid_attrs.typical)
      assert link.category == @valid_attrs.typical.category
      assert link.label == @valid_attrs.typical.label
      assert link.url == @valid_attrs.typical.url

      #min
      assert {:ok, %Link{} = link} = Links.create_link(contact, @valid_attrs.min)
      assert link.category == nil
      assert link.label == nil
      assert link.url == @valid_attrs.min.url
    end

    test "create_link/1 with invalid data returns error changeset" do
      {group, project, contact} = owner_fixtures()

      # is nil
      assert {:error, %Ecto.Changeset{}} = Links.create_link(group, @invalid_attrs.is_nil)
      assert {:error, %Ecto.Changeset{}} = Links.create_link(project, @invalid_attrs.is_nil)
      assert {:error, %Ecto.Changeset{}} = Links.create_link(contact, @invalid_attrs.is_nil)

      # bad format
      assert {:error, %Ecto.Changeset{}} = Links.create_link(group, @invalid_attrs.bad_format)
      assert {:error, %Ecto.Changeset{}} = Links.create_link(project, @invalid_attrs.bad_format)
      assert {:error, %Ecto.Changeset{}} = Links.create_link(contact, @invalid_attrs.bad_format)

      # too short
      assert {:error, %Ecto.Changeset{}} = Links.create_link(group, @invalid_attrs.too_short)
      assert {:error, %Ecto.Changeset{}} = Links.create_link(project, @invalid_attrs.too_short)
      assert {:error, %Ecto.Changeset{}} = Links.create_link(contact, @invalid_attrs.too_short)

      # too long
      assert {:error, %Ecto.Changeset{}} = Links.create_link(group, @invalid_attrs.too_long)
      assert {:error, %Ecto.Changeset{}} = Links.create_link(project, @invalid_attrs.too_long)
      assert {:error, %Ecto.Changeset{}} = Links.create_link(contact, @invalid_attrs.too_long)
    end

    test "the database's has_exactly_one_owner check constraint throws and error if a link has no or multiple owners"

    test "update_link/2 with valid data updates the link" do
      {group, _, _} = owner_fixtures()
      link = link_fixture(group)

      # typical
      assert {:ok, link} = Links.update_link(link, @update_attrs.typical)
      assert %Link{} = link
      assert link.category == @update_attrs.typical.category
      assert link.label == @update_attrs.typical.label
      assert link.url == @update_attrs.typical.url
    end

    test "update_link/2 with invalid data returns error changeset" do
      {group, _, _} = owner_fixtures()
      link = link_fixture(group)

      # is nil
      assert {:error, %Ecto.Changeset{}} = Links.update_link(link, @invalid_attrs.is_nil)
      assert link == Links.get_link!(link.id)

      # bad format
      assert {:error, %Ecto.Changeset{}} = Links.update_link(link, @invalid_attrs.bad_format)
      assert link == Links.get_link!(link.id)

      # too short
      assert {:error, %Ecto.Changeset{}} = Links.update_link(link, @invalid_attrs.too_short)
      assert link == Links.get_link!(link.id)

      # too long
      assert {:error, %Ecto.Changeset{}} = Links.update_link(link, @invalid_attrs.too_long)
      assert link == Links.get_link!(link.id)
    end

    test "delete_link/1 deletes the link" do
      {group, _, _} = owner_fixtures()
      link = link_fixture(group)

      assert {:ok, %Link{}} = Links.delete_link(link)
      assert_raise Ecto.NoResultsError, fn -> Links.get_link!(link.id) end
    end

    test "the database's on_delete:delete_all setting deletes related links when a group is deleted"

    test "the database's on_delete:delete_all setting deletes related links when a project is deleted"

    test "the database's on_delete:delete_all setting deletes related links when a contact is deleted"

    test "change_link/1 returns a link changeset" do
      {group, _, _} = owner_fixtures()
      link = link_fixture(group)

      assert %Ecto.Changeset{} = Links.change_link(link)
    end
  end
end
