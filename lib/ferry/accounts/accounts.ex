defmodule Ferry.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto
  import Ecto.Query, warn: false
  alias Ferry.Repo

  alias Ferry.Accounts.User
  alias Ferry.Profiles.Group

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

  ## Examples

      iex> create_user(%Group{}, %{field: value})
      {:ok, %User{}}

      iex> create_user(%Group{} %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(%Group{} = group, attrs \\ %{}) do
    build_assoc(group, :users)
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
  # # TODO
  # def update_user(%User{} = user, attrs) do
  #   user
  #   |> User.changeset(attrs)
  #   |> Repo.update()
  # end

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
end