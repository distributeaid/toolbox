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

  # Emails
  # ==============================================================================  
  describe "emails" do
    alias Ferry.CRM.{Contact, Email}

    # Data & Helpers
    # ----------------------------------------------------------
    # These are attributes for the Contact.emails field.
    @valid_emails_attr %{
      typical: %{emails: [
        %{email: "email1@example.com"},
        %{email: "email2@example.com"}
      ]}
    }

    @update_emails_attr %{
      # 1st and 2nd emails should remain, 3rd email should be added
      addition: %{emails: [
        %{email: "email1@example.com"},
        %{email: "email2@example.com"},
        %{email: "new_email@example.com"}
      ]},

      # 1st email should remain, 2nd email should be removed
      removal: %{emails: [
        %{email: "email1@example.com"}
      ]},

      # 1st email should remain, 2nd email should be replaced
      replacement: %{emails: [
        %{email: "email1@example.com"},
        %{email: "new_email@example.com"}
      ]}
    }

    @invalid_emails_attr %{
      is_nil: %{emails: [nil]},

      bad_format: %{emails: [
        %{email: "not_an_email"}
      ]},

      too_long: %{emails: [
        %{email: "way_too_long_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx@example.com"}
      ]}
    }

    # Tests
    # ----------------------------------------------------------

    test "list_contacts/1 includes emails when returning all contacts for a group" do
      {group1, _} = group_and_project_fixtures(1)
      {group2, _} = group_and_project_fixtures(2)

      email3 = %{email: "email3@example.com"}
      email4 = %{email: "email4@example.com"}

      contact1 = contact_fixture(group1, @valid_emails_attr.typical)
      contact2 = contact_fixture(group1, %{emails: [email3]})
      _ = contact_fixture(group2, %{emails: [email4]})

      # all emails are included for the specified group
      contacts = CRM.list_contacts(group1)
      assert contacts == [contact1, contact2]
    end

    test "list_contacts/1 includes emails when returning all contacts for a project" do
      {_, project1} = group_and_project_fixtures(1)
      {_, project2} = group_and_project_fixtures(2)

      email1 = %{email: "email1@example.com"}
      email2 = %{email: "email2@example.com"}
      email3 = %{email: "email3@example.com"}
      email4 = %{email: "email4@example.com"}

      contact1 = contact_fixture(project1, @valid_emails_attr.typical)
      contact2 = contact_fixture(project1, %{emails: [email3]})
      _ = contact_fixture(project2, %{emails: [email4]})

      # all emails are included for the specified group
      contacts = CRM.list_contacts(project1)
      assert contacts == [contact1, contact2]
    end

    test "get_contact!/1 includes emails when returning the contact with given id" do
      {group, _} = group_and_project_fixtures()
      contact = contact_fixture(group, @valid_emails_attr.typical)
      assert CRM.get_contact!(contact.id) == contact
    end

    test "create_contact/2 with valid data creates a contact with emails for a group" do
      {group, _} = group_and_project_fixtures()
      contact_attrs = Enum.into(@valid_emails_attr.typical, @valid_attrs.typical)

      # typical
      assert {:ok, %Contact{} = contact} = CRM.create_contact(group, contact_attrs)
      assert 2 == length(contact.emails)
      assert Enum.at(contact.emails, 0).email == Enum.at(@valid_emails_attr.typical.emails, 0).email
      assert Enum.at(contact.emails, 1).email == Enum.at(@valid_emails_attr.typical.emails, 1).email
    end

    test "create_contact/2 with valid data creates a contact with emails for a project" do
      {_, project} = group_and_project_fixtures()
      contact_attrs = Enum.into(@valid_emails_attr.typical, @valid_attrs.typical)

      # typical
      assert {:ok, %Contact{} = contact} = CRM.create_contact(project, contact_attrs)
      assert 2 == length(contact.emails)
      assert Enum.at(contact.emails, 0).email == Enum.at(@valid_emails_attr.typical.emails, 0).email
      assert Enum.at(contact.emails, 1).email == Enum.at(@valid_emails_attr.typical.emails, 1).email
    end

    test "create_contact/1 with invalid email data returns error changeset" do
      {group, project} = group_and_project_fixtures()

      # is nil
      contact_with_invalid_email_attrs = Enum.into(@invalid_emails_attr.is_nil, @valid_attrs.typical)
      assert {:error, %Ecto.Changeset{}} = CRM.create_contact(group, contact_with_invalid_email_attrs)
      assert {:error, %Ecto.Changeset{}} = CRM.create_contact(project, contact_with_invalid_email_attrs)

      # bad format
      contact_with_invalid_email_attrs = Enum.into(@invalid_emails_attr.bad_format, @valid_attrs.typical)
      assert {:error, %Ecto.Changeset{}} = CRM.create_contact(group, contact_with_invalid_email_attrs)
      assert {:error, %Ecto.Changeset{}} = CRM.create_contact(project, contact_with_invalid_email_attrs)

      # too long
      contact_with_invalid_email_attrs = Enum.into(@invalid_emails_attr.too_long, @valid_attrs.typical)
      assert {:error, %Ecto.Changeset{}} = CRM.create_contact(group, contact_with_invalid_email_attrs)
      assert {:error, %Ecto.Changeset{}} = CRM.create_contact(project, contact_with_invalid_email_attrs)
    end

    # TODO: The update tests actually removes all of the old Emails and adds new
    #       database entries.  Functionally it doesn't matter- in practice there
    #       might be a small performance hit.  The test should be updated to
    #       reflect what happens in practice:
    #
    #         - Does the frontend return a list of strings? If so, the update
    #           tests accurately reflect the behavior and performance.
    #         - Does the frontend return Email objects for existing / updated
    #           entries?  If so the test should be changed to use email objects.
    #           Note that adding new emails is reflected accurately either way,
    #           since those will just be email strings.
    test "update_contact/2 with valid data adds new emails" do
      {group, _} = group_and_project_fixtures()
      contact_with_email_attrs = Enum.into(@valid_emails_attr.typical, @valid_attrs.typical)
      contact = contact_fixture(group, contact_with_email_attrs)

      # addition
      assert {:ok, contact} = CRM.update_contact(contact, @update_emails_attr.addition)
      assert %Contact{} = contact
      assert 3 == length(contact.emails)
      assert Enum.at(contact.emails, 0).email == Enum.at(@valid_emails_attr.typical.emails, 0).email
      assert Enum.at(contact.emails, 1).email == Enum.at(@valid_emails_attr.typical.emails, 1).email
      assert Enum.at(contact.emails, 2).email == Enum.at(@update_emails_attr.addition.emails, 2).email
    end

    # See note about update_contact/2 email tests above.
    test "update_contact/2 with valid data deletes removed emails" do
      {group, _} = group_and_project_fixtures()
      contact_with_email_attrs = Enum.into(@valid_emails_attr.typical, @valid_attrs.typical)
      contact = contact_fixture(group, contact_with_email_attrs)

      # removal
      assert {:ok, contact} = CRM.update_contact(contact, @update_emails_attr.removal)
      assert %Contact{} = contact
      assert 1 == length(contact.emails)
      assert Enum.at(contact.emails, 0).email == Enum.at(@valid_emails_attr.typical.emails, 0).email
    end

    # See note about update_contact/2 email tests above.
    test "update_contact/2 with valid data replaces changed emails" do
      {group, _} = group_and_project_fixtures()
      contact_with_email_attrs = Enum.into(@valid_emails_attr.typical, @valid_attrs.typical)
      contact = contact_fixture(group, contact_with_email_attrs)

      # addition
      assert {:ok, contact} = CRM.update_contact(contact, @update_emails_attr.replacement)
      assert %Contact{} = contact
      assert 2 == length(contact.emails)
      assert Enum.at(contact.emails, 0).email == Enum.at(@valid_emails_attr.typical.emails, 0).email
      assert Enum.at(contact.emails, 1).email == Enum.at(@update_emails_attr.replacement.emails, 1).email
    end

    test "update_contact/2 with invalid email data returns error changeset" do
      {group, _} = group_and_project_fixtures()
      contact_with_email_attrs = Enum.into(@valid_emails_attr.typical, @valid_attrs.typical)
      contact = contact_fixture(group, contact_with_email_attrs)

      # is nil
      assert {:error, %Ecto.Changeset{}} = CRM.update_contact(contact, @invalid_emails_attr.is_nil)
      assert contact == CRM.get_contact!(contact.id)

      # bad format
      assert {:error, %Ecto.Changeset{}} = CRM.update_contact(contact, @invalid_emails_attr.bad_format)
      assert contact == CRM.get_contact!(contact.id)

      # too long
      assert {:error, %Ecto.Changeset{}} = CRM.update_contact(contact, @invalid_emails_attr.too_long)
      assert contact == CRM.get_contact!(contact.id)
    end

    test "delete_contact/1 also deletes the emails associated with a contact" do
      {group, _} = group_and_project_fixtures()
      contact_with_email_attrs = Enum.into(@valid_emails_attr.typical, @valid_attrs.typical)
      contact = contact_fixture(group, contact_with_email_attrs)

      assert {:ok, %Contact{}} = CRM.delete_contact(contact)
      assert [] == Repo.all(
        from e in Email,
          where: e.contact_id == ^contact.id
      )
    end
  end
end
