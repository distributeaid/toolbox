defmodule Ferry.Shipments do
  @moduledoc """
  The Shipments context.
  """

  import Ecto.Query, warn: false
  alias Ferry.Repo
  alias Ferry.Profiles.Group

  alias Ferry.Shipments.Shipment

  @doc """
  Returns the list of shipments.

  ## Examples

      iex> list_shipments()
      [%Shipment{}, ...]

  """
  def list_shipments do
    Repo.all(Shipment)
  end

  def list_shipments(%Group{} = group) do
    Repo.all(
      from s in Shipment,
      where: s.group_id == ^group.id,
      order_by: s.id
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
  def get_shipment!(id), do: Repo.get!(Shipment, id)

  @doc """
  Creates a shipment.

  ## Examples

      iex> create_shipment(%{field: value})
      {:ok, %Shipment{}}

      iex> create_shipment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_shipment(attrs \\ %{}) do
    %Shipment{}
    |> Shipment.changeset(attrs)
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
end
