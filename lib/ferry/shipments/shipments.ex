defmodule Ferry.Shipments do
  @moduledoc """
  The Shipments context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Ferry.Repo

  alias Ferry.Profiles.Group
  alias Ferry.Shipments.Role
  alias Ferry.Shipments.Shipment
  alias Ferry.Shipments.Route

  # Shipment
  # ==============================================================================

  @doc """
  Returns the list of shipments.

  ## Examples

      iex> list_shipments()
      [%Shipment{}, ...]

  """
  def list_shipments do
    Repo.all(
      from s in Shipment,
      order_by: s.id,
      left_join: r in assoc(s, :roles),
      left_join: g in assoc(r, :group),
      preload: [
        roles: {r, group: g},
        routes: ^routes_query()
      ]
    )
  end

  def list_shipments(%Group{} = group) do
    Repo.all(
      from s in Shipment,
      order_by: s.id,
      left_join: r in assoc(s, :roles),
      where: r.group_id == ^group.id,

      # TODO: Can we do all the queries in one go? Currently need to do extra
      # queries for these.  If you try to inline it (see list_shipments/0 above)
      # then the where clause will only select the 1 role that the group is in.
      preload: [
        roles: :group,
        routes: ^routes_query()
      ]
    )
  end

  @doc """
  Gets a single shipment.

  Raises `Ecto.NoResultsError` if the Shipment does not exist.

  ## Examples

      iex> get_shipment!(123)
      %Shipment{}

      iex> get_shipment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_shipment!(id) do
    query = from s in Shipment,
      left_join: r in assoc(s, :roles),
      left_join: g in assoc(r, :group),
      preload: [
        roles: {r, group: g},
        routes: ^routes_query()
      ]

    Repo.get!(query, id)
  end

  @doc """
  Creates a shipment.

  ## Examples

      iex> create_shipment(%{field: value})
      {:ok, %Shipment{}}

      iex> create_shipment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_shipment(attrs \\ %{}) do
    # TODO: validate that at least 1 role exists to prevent orphan shipments
    #       currently enforced through the UI
    %Shipment{}
    |> Shipment.changeset(attrs)
    |> Changeset.cast_assoc(:roles)
    |> Changeset.cast_assoc(:routes)
    |> Repo.insert()
  end

  @doc """
  Updates a shipment.

  ## Examples

      iex> update_shipment(shipment, %{field: new_value})
      {:ok, %Shipment{}}

      iex> update_shipment(shipment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_shipment(%Shipment{} = shipment, attrs) do
    shipment
    |> Shipment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Shipment.

  ## Examples

      iex> delete_shipment(shipment)
      {:ok, %Shipment{}}

      iex> delete_shipment(shipment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_shipment(%Shipment{} = shipment) do
    Repo.delete(shipment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking shipment changes.

  ## Examples

      iex> change_shipment(shipment)
      %Ecto.Changeset{source: %Shipment{}}

  """
  def change_shipment(%Shipment{} = shipment) do
    Shipment.changeset(shipment, %{})
  end

  # Roles
  # ================================================================================

  def get_role!(id) do
    query = from r in Role,
      join: g in assoc(r, :group),
      preload: [group: g]

    Repo.get!(query, id)
  end

  def create_role(attrs \\ %{}) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end

  # TODO: shouldn't be able to change group / shipment
  def update_role(%Role{} = role, attrs) do
    role
    |> Role.changeset(attrs)
    |> Repo.update()
  end

  def delete_role(%Role{} = role) do
    shipment = get_shipment!(role.shipment_id)

    cond do
      length(shipment.roles) > 1 -> Repo.delete(role)
      true ->
        role # TODO: make into a delete changeset?
        |> Changeset.change()
        |> Changeset.add_error(:shipment, "There must be at least 1 group taking part in this shipment.")
        |> Changeset.apply_action(:delete)
    end
  end

  def change_role(%Role{} = role) do
    Role.changeset(role, %{})
  end

  # Route
  # ==============================================================================

  defp routes_query do
    from r in Route,
    order_by: r.date
  end

  @doc """
  Returns the list of routes.

  ## Examples

      iex> list_routes(shipment)
      [%Route{}, ...]

  """
  def list_routes(%Shipment{} = shipment) do
    Repo.all(
      from r in routes_query(),
      where: r.shipment_id == ^shipment.id
    )
  end

  @doc """
  Gets a single route.

  Raises `Ecto.NoResultsError` if the Route does not exist.

  ## Examples

      iex> get_route!(123)
      %Route{}

      iex> get_route!(456)
      ** (Ecto.NoResultsError)

  """
  def get_route!(id), do: Repo.get!(Route, id)

  @doc """
  Creates a route.

  ## Examples

      iex> create_route(%{field: value})
      {:ok, %Route{}}

      iex> create_route(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_route(attrs \\ %{}) do
    %Route{}
    |> Route.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a route.

  ## Examples

      iex> update_route(route, %{field: new_value})
      {:ok, %Route{}}

      iex> update_route(route, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_route(%Route{} = route, attrs) do
    route
    |> Route.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Route.

  ## Examples

      iex> delete_route(route)
      {:ok, %Route{}}

      iex> delete_route(route)
      {:error, %Ecto.Changeset{}}

  """
  def delete_route(%Route{} = route) do
    Repo.delete(route)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking route changes.

  ## Examples

      iex> change_route(route)
      %Ecto.Changeset{source: %Route{}}

  """
  def change_route(%Route{} = route) do
    Route.changeset(route, %{})
  end

end
