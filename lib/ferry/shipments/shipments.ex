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
      preload: [roles: {r, group: g}]
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
      preload: [roles: :group]
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
      preload: [roles: {r, group: g}]

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
    # TODO: force at least 1 role to exist to prevent orphan shipments
    %Shipment{}
    |> Shipment.changeset(attrs)
    |> Changeset.cast_assoc(:roles)
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

  def create_role(%Group{} = group, %Shipment{} = shipment, attrs \\ %{}) do
    attrs = Map.merge(attrs, %{
      group_id: group.id,
      shipment_id: shipment.id
    })

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

  # TODO: force at least 1 role to exist to prevent orphan shipments
  def delete_role(%Role{} = role) do
    Repo.delete(role)
  end

  def change_role(%Role{} = role) do
    Role.changeset(role, %{})
  end
end
