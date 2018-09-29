defmodule Ferry.CRMTest do
  use Ferry.DataCase

  alias Ferry.CRM

  # Contacts
  # ==============================================================================
  describe "contacts" do
    alias Ferry.Profiles
    alias Ferry.CRM.Contact

    # Data & Helpers
    # ----------------------------------------------------------

    @valid_attrs %{
      typical: %{label: "General Inquiries", description: "Hit us up!"},
      min: %{}
    }

    @update_attrs %{
      typical: %{label: "Distribution - Muhammad", description: "Muhammad handles our distribution.  Contact him regarding the warehouse and to coordinate on shipments."}
    }

    @invalid_attrs %{
      too_long: %{label: "This is really way too long. xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}
    }

    def contact_fixture(owner, attrs \\ %{}) do
      attrs = Enum.into(attrs, @valid_attrs.typical)
      {:ok, contact} = CRM.create_contact(owner, attrs)

      contact
    end

    def group_and_project_fixtures(n \\ 1) do
      n = Integer.to_string(n)
      {:ok, group} = Profiles.create_group(%{name: "Food Clothing and Resistance Collective " <> n})
      {:ok, project} = Profiles.create_project(group, %{name: "Feed The People " <> n})

      {group, project}
    end

    # Tests
    # ----------------------------------------------------------
    # NOTE: Functions like create_contact/2 which are required to distinguish
    #       between contact owners (groups or projects) must test with both.
    #       Other functions like list_contacts/0 may only test with one.
    test "list_contacts/1 returns all contacts for a group" do
      {group, project} = group_and_project_fixtures(1)
      {group2, _} = group_and_project_fixtures(2)

      # no contacts
      assert CRM.list_contacts(group) == []

      # 1 contact
      contact1 = contact_fixture(group)
      assert CRM.list_contacts(group) == [contact1]

      # n contacts
      contact2 = contact_fixture(group)
      assert CRM.list_contacts(group) == [contact1, contact2]

      # only contacts for that group
      _ = contact_fixture(group2)
      _ = contact_fixture(project)
      assert CRM.list_contacts(group) == [contact1, contact2]
    end

    test "list_contacts/1 returns all contacts for a project" do
      {group, project} = group_and_project_fixtures(1)
      {_, project2} = group_and_project_fixtures(2)

      # no contacts
      assert CRM.list_contacts(project) == []

      # 1 contact
      contact1 = contact_fixture(project)
      assert CRM.list_contacts(project) == [contact1]

      # n contacts
      contact2 = contact_fixture(project)
      assert CRM.list_contacts(project) == [contact1, contact2]

      # only contacts for group
      _ = contact_fixture(group)
      _ = contact_fixture(project2)
      assert CRM.list_contacts(project) == [contact1, contact2]
    end

    test "get_contact!/1 returns the contact with given id" do
      {group, _} = group_and_project_fixtures()
      contact = contact_fixture(group)
      assert CRM.get_contact!(contact.id) == contact
    end

    test "get_contact!/1 with a non-existent id throws and error" do
      assert_raise Ecto.NoResultsError, ~r/^expected at least one result but got none in query/, fn ->
        CRM.get_contact!(1312)
      end
    end

    test "create_contact/2 with valid data creates a contact for a group" do
      {group, _} = group_and_project_fixtures()

      # typical
      assert {:ok, %Contact{} = contact} = CRM.create_contact(group, @valid_attrs.typical)
      assert contact.label == @valid_attrs.typical.label
      assert contact.description == @valid_attrs.typical.description

      # min
      assert {:ok, %Contact{} = contact} = CRM.create_contact(group, @valid_attrs.min)
      assert contact.label == nil
      assert contact.description == nil
    end

    test "create_contact/2 with valid data creates a contact for a project" do
      {_, project} = group_and_project_fixtures()

      # typical
      assert {:ok, %Contact{} = contact} = CRM.create_contact(project, @valid_attrs.typical)
      assert contact.label == @valid_attrs.typical.label
      assert contact.description == @valid_attrs.typical.description

      # min
      assert {:ok, %Contact{} = contact} = CRM.create_contact(project, @valid_attrs.min)
      assert contact.label == nil
      assert contact.description == nil
    end

    test "create_contact/1 with invalid data returns error changeset" do
      {group, project} = group_and_project_fixtures()

      # too long
      assert {:error, %Ecto.Changeset{}} = CRM.create_contact(group, @invalid_attrs.too_long)
      assert {:error, %Ecto.Changeset{}} = CRM.create_contact(project, @invalid_attrs.too_long)
    end

    test "the database's has_exactly_one_owner check constraint throws and error if a contact has no or multiple owners"

    test "update_contact/2 with valid data updates the contact" do
      {group, _} = group_and_project_fixtures()
      contact = contact_fixture(group)

      # typical
      assert {:ok, contact} = CRM.update_contact(contact, @update_attrs.typical)
      assert %Contact{} = contact
      assert contact.label == @update_attrs.typical.label
      assert contact.description == @update_attrs.typical.description
    end

    test "update_contact/2 with invalid data returns error changeset" do
      {group, _} = group_and_project_fixtures()
      contact = contact_fixture(group)

      # too long
      assert {:error, %Ecto.Changeset{}} = CRM.update_contact(contact, @invalid_attrs.too_long)
      assert contact == CRM.get_contact!(contact.id)
    end

    test "delete_contact/1 deletes the contact" do
      {group, _} = group_and_project_fixtures()
      contact = contact_fixture(group)
      assert {:ok, %Contact{}} = CRM.delete_contact(contact)
      assert_raise Ecto.NoResultsError, fn -> CRM.get_contact!(contact.id) end
    end

    test "the database's on_delete:delete_all setting deletes related contacts when a group is deleted"

    test "the database's on_delete:delete_all setting deletes related contacts when a project is deleted"

    test "change_contact/1 returns a contact changeset" do
      {group, _} = group_and_project_fixtures()
      contact = contact_fixture(group)
      assert %Ecto.Changeset{} = CRM.change_contact(contact)
    end
  end
end
