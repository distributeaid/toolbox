defmodule Ferry.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Ferry.Repo

  alias Ferry.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.
  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  # @doc """
  # Updates a user.

  # ## Examples

  #     iex> update_user(user, %{field: new_value})
  #     {:ok, %User{}}

  #     iex> update_user(user, %{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  # @doc """
  # Deletes a User.

  # ## Examples

  #     iex> delete_user(user)
  #     {:ok, %User{}}

  #     iex> delete_user(user)
  #     {:error, %Ecto.Changeset{}}

  # """
  # # TODO: should only be able to delete a user by deleting a group and having it cascade
  # def delete_user(%User{} = user) do
  #   Repo.delete(user)
  # end

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
  Find a user by his/her email
  """
  @spec get_user_by_email(String.t()) :: {:ok, User.t()} | :not_found
  def get_user_by_email(email) do
    case User |> Repo.get_by(email: email) do
      nil ->
        :not_found

      user ->
        {:ok, user}
    end
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

    user
    |> User.changeset(attrs)
    |> Repo.insert_or_update()
  end
end
