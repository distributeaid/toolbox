defmodule Ferry.Locations do
  @moduledoc """
  The Locations context.
  """

  import Ecto
  import Ecto.Query, warn: false
  alias Ferry.Repo

  alias Ferry.Profiles.{Group, Project}
  alias Ferry.Locations.Address

  @doc """
  Returns the list of addresses.

  ## Examples

      iex> list_addresses()
      [%Address{}, ...]

  """
  def list_addresses do
    Repo.all(Address)
  end

  @doc """
  Returns a list of countries.

  ## Examples

      iex> list_countries()
      ["France", "Greece", "Serbia", ...]

  """
  def list_countries do
    throw "Ferry.Locations.list_countries/0 is not implemented... yet ;)"
  end

  @doc """
  Returns a list of city & country tuples.

  ## Examples

      iex> list_cities()
      [{"Calais", "France"}, {"Caen", "France"}, {"Rome", "Italy"}, ...]

  """
  def list_cities do
    throw "Ferry.Locations.list_cities/0 is not implemented... yet ;)"
  end

  @doc """
  Returns a list of city & country tuples for the specified country.

  ## Examples

      iex> list_cities("France")
      [{"Calais", "France"}, {"Caen", "France"}, ...]

  """
  def list_cities(country) do
    throw "Ferry.Locations.list_cities/1 is not implemented... yet ;)"
  end

  @doc """
  Gets a single address.

  Raises `Ecto.NoResultsError` if the Address does not exist.

  ## Examples

      iex> get_address!(123)
      %Address{}

      iex> get_address!(456)
      ** (Ecto.NoResultsError)

  """
  def get_address!(id), do: Repo.get!(Address, id)

  @doc """
  Creates a address.

  ## Examples

      iex> create_address(%Group{}, %{field: value})
      {:ok, %Address{}}

      iex> create_address(%Project{}, %{field: value})
      {:ok, %Address{}}

      iex> create_address(%Group{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

      iex> create_address(%Project{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_address(owner, attrs \\ %{})

  def create_address(%Group{} = group, attrs) do
    %Address{}
    |> Address.changeset(attrs)
    |> Ecto.Changeset.put_change(:group_id, group.id)
    |> Repo.insert()
  end

  def create_address(%Project{} = project, attrs) do
    %Address{}
    |> Address.changeset(attrs)
    |> Ecto.Changeset.put_change(:project_id, project.id)
    |> Repo.insert()
  end

  @doc """
  Updates a address.

  ## Examples

      iex> update_address(address, %{field: new_value})
      {:ok, %Address{}}

      iex> update_address(address, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_address(%Address{} = address, attrs) do
    address
    |> Address.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Address.

  ## Examples

      iex> delete_address(address)
      {:ok, %Address{}}

      iex> delete_address(address)
      {:error, %Ecto.Changeset{}}

  """
  def delete_address(%Address{} = address) do
    Repo.delete(address)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking address changes.

  ## Examples

      iex> change_address(address)
      %Ecto.Changeset{source: %Address{}}

  """
  def change_address(%Address{} = address) do
    Address.changeset(address, %{})
  end
end
