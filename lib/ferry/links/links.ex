defmodule Ferry.Links do
  @moduledoc """
  The Links context.
  """

  import Ecto.Query, warn: false
  alias Ferry.Repo

  # Link
  # ==============================================================================
  alias Ferry.Profiles.{Group, Project}
  alias Ferry.CRM.Contact
  alias Ferry.Links.Link

  @doc """
  Returns the list of links for a group, project, or contact.

  ## Examples

      iex> list_links(%Group{})
      [%Link{}, ...]

      iex> list_links(%Project{})
      [%Link{}, ...]

      iex> list_links(%Contact{})
      [%Link{}, ...]
  """
  def list_links(%Group{} = group) do
    Repo.all(
      from l in Link,
        where: l.group_id == ^group.id,
        order_by: [l.id]
    )
  end

  def list_links(%Project{} = project) do
    Repo.all(
      from l in Link,
        where: l.project_id == ^project.id,
        order_by: [l.id]
    )
  end

  def list_links(%Contact{} = contact) do
    Repo.all(
      from l in Link,
        where: l.contact_id == ^contact.id,
        order_by: [l.id]
    )
  end

  @doc """
  Gets a single link.

  Raises `Ecto.NoResultsError` if the Link does not exist.

  ## Examples

      iex> get_link!(123)
      %Link{}

      iex> get_link!(456)
      ** (Ecto.NoResultsError)

  """
  def get_link!(id), do: Repo.get!(Link, id)

  @doc """
  Creates a link.

  ## Examples

      iex> create_link(%Group{}, %{field: value})
      {:ok, %Link{}}

      iex> create_link(%Project{}, %{field: value})
      {:ok, %Link{}}

      iex> create_link(%Contact{}, %{field: value})
      {:ok, %Link{}}

      iex> create_link(%Group{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

      iex> create_link(%Project{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

      iex> create_link(%Contact{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_link(owner, attrs \\ %{})

  def create_link(%Group{} = group, attrs) do
    %Link{}
    |> Link.changeset(attrs)
    |> Ecto.Changeset.put_change(:group_id, group.id)
    |> Repo.insert()
  end

  def create_link(%Project{} = project, attrs) do
    %Link{}
    |> Link.changeset(attrs)
    |> Ecto.Changeset.put_change(:project_id, project.id)
    |> Repo.insert()
  end

  def create_link(%Contact{} = contact, attrs) do
    %Link{}
    |> Link.changeset(attrs)
    |> Ecto.Changeset.put_change(:contact_id, contact.id)
    |> Repo.insert()
  end

  @doc """
  Updates a link.

  ## Examples

      iex> update_link(link, %{field: new_value})
      {:ok, %Link{}}

      iex> update_link(link, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_link(%Link{} = link, attrs) do
    link
    |> Link.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Link.

  ## Examples

      iex> delete_link(link)
      {:ok, %Link{}}

      iex> delete_link(link)
      {:error, %Ecto.Changeset{}}

  """
  def delete_link(%Link{} = link) do
    Repo.delete(link)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking link changes.

  ## Examples

      iex> change_link(link)
      %Ecto.Changeset{source: %Link{}}

  """
  def change_link(%Link{} = link) do
    Link.changeset(link, %{})
  end
end
