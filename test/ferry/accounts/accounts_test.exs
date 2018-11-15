defmodule Ferry.AccountsTest do
  use Ferry.DataCase

  alias Ferry.Accounts

  # Users
  # ==============================================================================
  describe "users" do
    alias Ferry.Profiles
    alias Ferry.Accounts.User

    # Data & Helpers
    # ----------------------------------------------------------

    @valid_attrs %{
      typical: %{email: "welcome.newcomers.1@example.org", password: "048urwcu0pmuqw0-c94u*(@$0"},
      min: %{email: "a@b.de", password: "123456789012"}
    }

    # @update_attrs %{
    #   typical: %{email: "welcome.newcomers.3@example.org", password: "2opqiurefdlaksjfO#Q$*@&#?"},
    #   email_only: %{email: "welcome.newcomers.4@example.org"},
    #   password_only: %{password: "lksdaj foia ej(*(FY*(WER##RDD"}
    # }

    @invalid_attrs %{
      is_nil: %{email: nil, password: nil},
      bad_format: %{email: "not_an_email", password: "üöäååø∂ßˆå√øπ∑å´˙ƒ¬åß˚∂∆ƒå´ "},
      too_short: %{email: "a@b", password: "1234"},
      too_long: %{email: "way_too_long_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx@example.com", password: "als;kdjfa 2834#(*$"},
    }

    def user_fixture(group, attrs \\ %{}) do
      attrs = Enum.into(attrs, @valid_attrs.typical)
      {:ok, user} = Accounts.create_user(group, attrs)

      user
    end

    def group_fixture(n \\ 1) do
      n = Integer.to_string(n)
      {:ok, group} = Profiles.create_group(%{name: "Antifa" <> n})

      group
    end

    # Tests
    # ----------------------------------------------------------

    test "list_users/0 returns all users" do
      group1 = group_fixture(1)
      group2 = group_fixture(2)

      # no users
      assert Accounts.list_users() == []

      # 1 user, 1 group
      user1 = user_fixture(group1)
      users = Accounts.list_users()
      assert users |> length == 1
      assert Enum.at(users, 0).id == user1.id

      # multiple users, multiple groups
      user2 = user_fixture(group2, %{email: "a_different_email@example.org"})
      users = Accounts.list_users()
      assert users |> length == 2
      assert Enum.at(users, 0).id == user1.id
      assert Enum.at(users, 1).id == user2.id
    end

    test "get_user!/1 returns the user with given id" do
      group = group_fixture()
      user = user_fixture(group)
      assert Accounts.get_user!(user.id).email == user.email
    end

    test "get_user!/1 with a non-existent id throws an error" do
      assert_raise Ecto.NoResultsError, ~r/^expected at least one result but got none in query/, fn ->
        Accounts.get_user!(1312)
      end
    end

    test "create_user/2 with valid data creates a user" do
      # typical
      group = group_fixture(1)
      assert {:ok, %User{} = user} = Accounts.create_user(group, @valid_attrs.typical)
      assert user.email == @valid_attrs.typical.email
      assert user.password == @valid_attrs.typical.password

      # min
      group = group_fixture(2)
      assert {:ok, %User{} = user} = Accounts.create_user(group, @valid_attrs.min)
      assert user.email == @valid_attrs.min.email
      assert user.password == @valid_attrs.min.password
    end

    test "create_user/2 with invalid data returns error changeset" do
      # is nil
      group = group_fixture(1)
      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.create_user(group, @invalid_attrs.is_nil)
      assert 2 == changeset.errors |> length

      # bad format
      group = group_fixture(2)
      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.create_user(group, @invalid_attrs.bad_format)
      assert 1 == changeset.errors |> length

      # too short
      group = group_fixture(3)
      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.create_user(group, @invalid_attrs.too_short)
      assert 2 == changeset.errors |> length

      # too long
      group = group_fixture(4)
      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.create_user(group, @invalid_attrs.too_long)
      assert 1 == changeset.errors |> length
    end

    test "change_user/1 returns a user changeset" do
      group = group_fixture()
      user = user_fixture(group)
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
