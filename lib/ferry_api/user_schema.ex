defmodule FerryApi.Schema.User do
  use Absinthe.Schema.Notation
  import AbsintheErrorPayload.Payload
  alias FerryApi.Middleware.{RequireUser, RequireDaOrGroupAdmin}
  alias Ferry.Accounts
  alias Ferry.Profiles

  object :user_queries do
    @desc "Get the number of users"
    field :count_users, :integer do
      middleware(RequireUser)
      resolve(&count_users/3)
    end

    @desc "Get all users"
    field :users, list_of(:user) do
      middleware(RequireUser)
      resolve(&get_users/3)
    end

    @desc "Get a user"
    field :user, :user do
      arg(:id, non_null(:id))
      middleware(RequireUser)
      resolve(&get_user/3)
    end
  end

  object :user_mutations do
    @desc "Set a user role"
    field :set_user_role, type: :user_payload do
      arg(:user, non_null(:id))
      arg(:group, non_null(:id))
      arg(:role, non_null(:string))
      middleware(RequireUser)
      middleware(RequireDaOrGroupAdmin)
      resolve(&set_user_role/3)
      middleware(&build_payload/2)
    end

    @desc "Delete a user role"
    field :delete_user_role, type: :user_payload do
      arg(:user, non_null(:id))
      arg(:group, non_null(:id))
      arg(:role, non_null(:string))
      middleware(RequireUser)
      middleware(RequireDaOrGroupAdmin)
      resolve(&delete_user_role/3)
      middleware(&build_payload/2)
    end
  end

  @user_not_found "User not found"
  @group_not_found "Group not found"
  @unauthorized "unauthorized"

  @doc """
  Counts all users in the system
  """
  @spec count_users(any(), any(), any()) :: {:ok, integer()}
  def count_users(_parent, _args, %{context: %{da_admin: true}}) do
    {:ok, Accounts.count_users()}
  end

  def count_users(_parent, _args, %{context: %{user_groups: groups}}) do
    {:ok, Accounts.count_users_from_groups(groups)}
  end

  @doc """
  Get all users in the system
  """
  @spec get_users(any(), any(), any()) :: {:ok, [Ferry.Accounts.User.t()]}
  def get_users(_parent, _args, %{context: %{da_admin: true}}) do
    {:ok, Accounts.get_users()}
  end

  def get_users(_parent, _args, %{context: %{user_groups: groups}}) do
    {:ok, Accounts.get_users_in_groups(groups)}
  end

  @doc """
  Get a single user by his/her id
  """
  @spec get_user(any(), %{id: String.t()}, any()) :: {:ok, map()} | {:error, String.t()}
  def get_user(_parent, %{id: id}, %{context: %{da_admin: true}}) do
    with :not_found <- Accounts.get_user(id) do
      {:error, @user_not_found}
    end
  end

  def get_user(_parent, %{id: id}, %{context: %{user_groups: groups}}) do
    case Accounts.get_user(id) do
      :not_found ->
        {:error, @user_not_found}

      {:ok, user} ->
        # since we are not a DA admin, we need to apply some
        # access control
        case Ferry.Accounts.user_in_some_group?(user, groups) do
          true ->
            {:ok, user}

          false ->
            {:error, @unauthorized}
        end
    end
  end

  @doc """
  Sets a role for a user in a group
  """
  @spec set_user_role(any(), %{user: String.t(), group: String.t(), role: String.t()}, any()) ::
          {:ok, map()} | {:error, String.t()}
  def set_user_role(_, %{user: user, group: group, role: role}, _resolution) do
    case Accounts.get_user(user) do
      :not_found ->
        {:error, @user_not_found}

      {:ok, user} ->
        case Profiles.get_group(group) do
          :not_found ->
            {:error, @group_not_found}

          {:ok, group} ->
            Accounts.set_user_role(user, group, role)
        end
    end

    # end
  end

  @doc """
  Deletes a role for a user from a group
  """
  @spec delete_user_role(any(), %{user: String.t(), group: String.t(), role: String.t()}, any()) ::
          {:ok, map()} | {:error, String.t()}
  def delete_user_role(_, %{user: user, group: group, role: role}, _resolution) do
    case Accounts.get_user(user) do
      :not_found ->
        {:error, @user_not_found}

      {:ok, user} ->
        case Profiles.get_group(group) do
          :not_found ->
            {:error, @group_not_found}

          {:ok, group} ->
            Accounts.delete_user_role(user, group, role)
        end
    end
  end
end
