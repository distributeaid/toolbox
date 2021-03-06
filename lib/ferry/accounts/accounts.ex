defmodule Ferry.Accounts do
  @moduledoc """
  The Accounts context.
  """
  import Ecto.Query, warn: false
  alias Ferry.Repo

  alias Ferry.Accounts.User
  alias Ferry.Accounts.UserGroup
  alias Ferry.Profiles.Group

  @doc """
  Counts all the users in the system
  """
  @spec count_users() :: integer()
  def count_users() do
    User
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Counts all the users that belong to any
  of the given groups
  """
  @spec count_users_from_groups([Group.t()]) :: integer()
  def count_users_from_groups(groups) do
    groups
    |> users_in_group_query()
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Returns the list of users.
  """
  @spec get_users() :: [User.t()]
  def get_users do
    Repo.all(User) |> Repo.preload(groups: [:group])
  end

  @doc """
  Returns the list of users that belong to any of the
  specified groups
  """
  @spec get_users_in_groups([Group.t()]) :: [User.t()]
  def get_users_in_groups(groups) do
    groups
    |> users_in_group_query()
    |> Repo.all()
    |> Repo.preload(groups: [:group])
  end

  defp users_in_group_query(groups) do
    group_ids = Enum.map(groups, fn g -> g.id end)

    from(u in User,
      distinct: true,
      join: ug in UserGroup,
      on: ug.user_id == u.id,
      where: ug.group_id in ^group_ids
    )
  end

  @doc """
  Returns wether the given user belongs to at least
  one of the given groups
  """
  @spec user_in_some_group?(User.t(), [Group.t()]) :: true | false
  def user_in_some_group?(user, groups) do
    user_groups = Enum.map(user.groups, fn ug -> ug.group end)
    length(user_groups -- user_groups -- groups) != 0
  end

  @doc """
  Gets a single user by his/her id
  """
  @spec get_user(integer() | String.t()) :: {:ok, User.t()} | :not_found
  def get_user(id) do
    case Repo.get(User, id) |> Repo.preload(groups: [:group]) do
      nil ->
        :not_found

      user ->
        {:ok, user}
    end
  end

  @doc """
  Find a user by his/her email
  """
  @spec get_user_by_email(String.t()) :: {:ok, User.t()} | :not_found
  def get_user_by_email(email) do
    case User |> Repo.get_by(email: email) |> Repo.preload(groups: [:group]) do
      nil ->
        :not_found

      user ->
        {:ok, user}
    end
  end

  @doc """
  Creates a user.
  """
  @spec create_user(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create_user(attrs \\ %{}) do
    with {:ok, user} <-
           %User{}
           |> User.changeset(attrs)
           |> Repo.insert() do
      get_user(user.id)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Inserts or updates a user, based on the given set of claims.

  This function is used when resolving a JWT token that is issued
  by an external authentication service
  """
  @spec insert_or_update_user(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def insert_or_update_user(%{"email" => email} = attrs) do
    user =
      case get_user_by_email(email) do
        {:ok, user} ->
          user

        :not_found ->
          %User{}
      end

    with {:ok, user} <-
           user
           |> User.changeset(attrs)
           |> Repo.insert_or_update() do
      get_user(user.id)
    end
  end

  @doc """
  Sets a role for a user in a group

  """
  @spec set_user_role(User.t(), Group.t(), String.t()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def set_user_role(user, group, role) do
    with {:ok, _} <-
           %UserGroup{}
           |> UserGroup.changeset(%{user_id: user.id, group_id: group.id, role: role})
           |> Repo.insert(
             on_conflict: {:replace, [:role]},
             conflict_target: [:user_id, :group_id]
           ) do
      get_user(user.id)
    end
  end

  @doc """
  Deletes a role for a user from a group

  """
  @spec delete_user_role(User.t(), Group.t(), String.t()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def delete_user_role(user, group, role) do
    with {_, nil} <-
           from(ug in UserGroup,
             where: ug.user_id == ^user.id and ug.group_id == ^group.id and ug.role == ^role
           )
           |> Repo.delete_all() do
      get_user(user.id)
    end
  end

  @doc """
  Returns whether the given user has the given role in the given
  group
  """
  @spec has_role?(User.t(), String.t(), String.t()) :: boolean()
  def has_role?(user, group_id, role) do
    Enum.count(user.groups, fn group ->
      "#{group.group.id}" == "#{group_id}" && group.role == role
    end) == 1
  end

  @doc """
  Returns whether the given user has any role in the given group
  """
  @spec has_role?(User.t(), String.t()) :: boolean()
  def has_role?(user, group_id) do
    Enum.count(user.groups, fn group ->
      "#{group.group.id}" == "#{group_id}"
    end) != 0
  end
end
