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
  Return the total number of shipments in the system
  """
  @spec count_shipments() :: non_neg_integer()
  def count_shipments() do
    Shipment
    |> Repo.aggregate(:count, :id)
  end

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
        preload: [
          roles: ^roles_query(),
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
        preload: [
          roles: ^roles_query(),
          routes: ^routes_query()
        ]
    )
  end

  @doc """
  Gets a single shipment.

  Returns nil if the shipment does not exist
  """
  @spec get_shipment(integer()) :: {:ok, Shipment.t()} | nil
  def get_shipment(id) do
    query =
      from s in Shipment,
        preload: [
          roles: ^roles_query(),
          routes: ^routes_query()
        ]

    Repo.get(query, id)
  end

  @doc """
  Creates a new shipment, for the given pickup and delivery addresses.

  """
  @spec create_shipment(map()) ::
          {:ok, Shipment.t()} | {:error, Ecto.ChangeError}
  def create_shipment(attrs) do
    # default status upon creation
    attrs = Map.put(attrs, :status, "planning")

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
  Deletes all shipments
  """
  @spec delete_shipments() :: boolean()
  def delete_shipments() do
    Shipment
    |> Repo.delete_all()

    true
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

  defp roles_query do
    from r in Role,
      left_join: g in assoc(r, :group),
      order_by: r.id,
      preload: [
        group: g
      ]
  end

  def get_role!(id) do
    query =
      from r in Role,
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
    shipment = get_shipment(role.shipment_id)

    if shipment != nil do
      if length(shipment.roles) > 1 do
        Repo.delete(role)
      else
        # TODO: make into a delete changeset?
        role
        |> Changeset.change()
        |> Changeset.add_error(
          :shipment,
          "There must be at least 1 group taking part in this shipment."
        )
        |> Changeset.apply_action(:delete)
      end
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
