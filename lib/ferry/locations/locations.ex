defmodule Ferry.Locations do
  @moduledoc """
  The Locations context.
  """

  import Ecto.Query, warn: false
  alias Ferry.Repo
  alias Ecto.Changeset

  alias Ferry.Profiles.{Group, Project}
  alias Ferry.Locations.Address

  @doc """
  Returns the list of addresses.

  ## Examples

      iex> list_addresses(%Group{})
      [%Address{}, ...]

      iex> list_addresses(%Project{})
      [%Address{}, ...]

  """
  def list_addresses(%Group{} = group) do
    Repo.all(from a in Address,
      where: a.group_id == ^group.id,
      order_by: [a.id]
    )
  end

  def list_addresses(%Project{} = project) do
    Repo.all(from a in Address,
      where: a.project_id == ^project.id,
      order_by: [a.id]
    )
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

  alias Ferry.Locations.Map

  @doc """
  Gets a map, which sets the search and filter fields and gets the matching
  addresses from the database.  Groups / projects are preloaded on each address.

  ## Examples

      iex> get_map(%{search: "...", country_filter: "RS"})
      {:ok, %Map{
        search: "...",
        country_filter: "RS",
        results: [%Address{
          label: "Collective Aid Processing Warehouse",
          ...,
          group: %Group{},
          project: %Project{}
        }, ...]
      }}

  """
  def get_map(attrs \\ %{}) do
    controls_changeset = %Map{} |> Map.changeset(attrs)

    unless controls_changeset.valid? do
      {:error, controls_changeset}

    else
      map = Changeset.apply_changes(controls_changeset)

      query = from a in Address,
        left_join: g in assoc(a, :group),
        left_join: p in assoc(a, :project),
        select: a,
        preload: [group: g, project: p]

      query = if map.group_filter != nil && length(map.group_filter) > 0 do
          from g in query,
            where: g.id in ^map.group_filter
        else
          query
        end

      results = Repo.all(from a in query)
      results_changeset = controls_changeset |> Map.changeset(%{results: results})

      unless results_changeset.valid? do
        {:error, results_changeset}
      else
        {:ok, Changeset.apply_changes(results_changeset)}
      end

    end

  end
end
