defmodule Ferry.Locations do
  @moduledoc """
  The Locations context.
  """

  import Ecto.Query, warn: false
  alias Ferry.Repo
  alias Ecto.Changeset

  # Address [w/ Geocode]
  # ==============================================================================
  alias Ferry.Profiles.Group
  alias Ferry.Locations.Address

  @geocoder Application.get_env(:ferry, :geocoder)

  defp geocode_address(%Changeset{valid?: true} = changeset) do
    case @geocoder.geocode_address(changeset.params) do
      {:ok, geocode} ->
        attrs = %{"geocode" => geocode}
        Address.geocode_changeset(changeset, attrs)
      {:error, error} ->
        IO.inspect error # TODO: proper error logging
        Changeset.add_error(changeset, :geocoding, "Our application server could not contact the geocoding server, which looks up and address's latitude and longitude.  Please try again in a few minutes, or contact us if this problem persists.")
    end
  end

  defp geocode_address(%Changeset{valid?: false} = changeset) do
    changeset
  end

  @doc """
  Returns the list of addresses.

  ## Examples

      iex> list_addresses(%Group{})
      [%Address{}, ...]

  """
  def list_addresses(%Group{} = group) do
    Repo.all(from a in Address,
      where: a.group_id == ^group.id,
      join: g in assoc(a, :geocode),
      preload: [geocode: g],
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
  def list_cities(_country) do
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
  def get_address!(id) do
    query = from a in Address,
      join: g in assoc(a, :geocode),
      preload: [geocode: g]

    Repo.get!(query, id)
  end

  @doc """
  Creates a address.

  ## Examples

      iex> create_address(%Group{}, %{field: value})
      {:ok, %Address{}}

      iex> create_address(%Group{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_address(%Group{} = group, attrs) do
    %Address{}
    |> Address.changeset(attrs)
    |> Changeset.put_change(:group_id, group.id)
    |> geocode_address()
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
    |> Repo.preload([:geocode])
    |> Address.changeset(attrs)
    |> geocode_address()
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


  # Map
  # ==============================================================================
  alias Ferry.Locations.Map

  @doc """
  Gets a map, which sets the search and filter fields and gets the matching
  addresses from the database.  Groups are preloaded on each address.

  ## Examples

      iex> get_map(%{search: "...", country_filter: "RS"})
      {:ok, %Map{
        search: "...",
        country_filter: "RS",
        results: [%Address{
          label: "Collective Aid Processing Warehouse",
          ...,
          group: %Group{}
        }, ...]
      }}

  """
  def get_map(attrs \\ %{}) do
    map_changeset = %Map{}
    |> set_control_labels()
    |> set_controls(attrs) 
    |> apply_controls()    

    if map_changeset.valid? do
      map = map_changeset |> Changeset.apply_changes()
      {:ok, map}
    else
      {:error, map_changeset}
    end
  end

  defp set_control_labels(%Map{} = map) do
    # TODO: move to Profiles context for better encapsulation?
    group_labels = Repo.all(from g in Group,
      select: {g.name, g.id},
      order_by: g.name
    )

    map
    |> Map.changeset(%{
      group_filter_labels: group_labels
      # add other control_labels here
    })
  end

  defp set_controls(%Changeset{} = map_changeset, attrs) do
    map_changeset |> Map.changeset(attrs)
  end

  defp apply_controls(%Changeset{valid?: false} = changeset) do
    changeset
  end

  defp apply_controls(%Changeset{valid?: true} = map_changeset) do
    map = map_changeset |> Changeset.apply_changes()

    query = from a in Address,
      left_join: g in assoc(a, :group),
      join: geo in assoc(a, :geocode),
      order_by: a.id,
      preload: [group: g, geocode: geo]

    {_, query} = {map, query}
    |> apply_group_filter() # returns {map, query}
    # add other control applications here

    results = Repo.all(from a in query)
    map_changeset |> Map.changeset(%{results: results})
  end

  defp apply_group_filter({%Map{group_filter: nil} = map, query}) do
    {map, query}
  end

  defp apply_group_filter({%Map{group_filter: []} = map, query}) do
    {map, query}
  end

  defp apply_group_filter({%Map{} = map, query}) do
    query = from [a, g] in query,
            where: g.id in ^map.group_filter

    {map, query}
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking map changes.

  ## Examples

      iex> change_map(map)
      %Ecto.Changeset{source: %Map{}}

  """
  def change_map(%Map{} = map) do
    Map.changeset(map, %{})
  end
end
