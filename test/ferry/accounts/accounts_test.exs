defmodule Ferry.AccountsTest do
  use Ferry.DataCase

  alias Ferry.Accounts

  # Users
  # ==============================================================================
  describe "users" do
    alias Ferry.Accounts.User

    # Tests
    # ----------------------------------------------------------

    test "list_users/0 returns all users" do
      group1 = insert(:group)
      group2 = insert(:group)

      # no users
      assert Accounts.list_users() == []

      # 1 user, 1 group
      user1 = insert(:user, %{group: group1})
      users = Accounts.list_users()
      assert users |> length == 1
      assert Enum.at(users, 0).id == user1.id
      assert Enum.at(users, 0).group_id == group1.id

      # multiple users, multiple groups
      user2 = insert(:user, %{group: group2})
      users = Accounts.list_users()
      assert users |> length == 2
      assert Enum.at(users, 0).id == user1.id
      assert Enum.at(users, 1).id == user2.id
    end

    test "get_user!/1 returns the user with given id" do
      group = insert(:group)
      user = insert(:user, %{group: group})
      assert Accounts.get_user!(user.id).email == user.email
    end

    test "get_user!/1 with a non-existent id throws an error" do
      assert_raise(
        Ecto.NoResultsError,
        ~r/^expected at least one result but got none in query/,
        fn ->
          Accounts.get_user!(1312)
        end
      )
    end

    test "create_user/2 with valid data creates a user" do
      group = insert(:group)
      user_params = params_for(:user)
      assert {:ok, %User{} = user} = Accounts.create_user(group, user_params)
      assert user.email == user_params.email
    end

    test "create_user/2 with invalid data returns error changeset" do
      group = insert(:group)

      # generally invalid
      invalid_params = params_for(:invalid_user)
      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.create_user(group, invalid_params)
      assert 1 == changeset.errors |> length

      # too long
      invalid_params = params_for(:invalid_long_user)
      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.create_user(group, invalid_params)
      assert 1 == changeset.errors |> length
    end

    test "update_user/2 with valid data updates the user" do
      group = insert(:group)
      user = insert(:user, %{group: group})

      # typical
      updated_params = params_for(:user)
      assert {:ok, %User{} = updated_user} = Accounts.update_user(user, updated_params)
      assert updated_user.id == user.id
      assert updated_user.group_id == user.group_id
      assert updated_user.email == updated_params.email
    end

    test "update_user/2 with invalid data returns error changeset" do
      group = insert(:group)
      user = insert(:user, %{group: group})

      # generally invalid
      invalid_params = params_for(:invalid_user)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, invalid_params)
      assert user = Accounts.get_user!(user.id)

      # too long
      invalid_params = params_for(:invalid_user)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, invalid_params)
      assert user = Accounts.get_user!(user.id)
    end

    test "change_user/1 returns a user changeset" do
      group = insert(:group)
      user = insert(:user, %{group: group})
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
