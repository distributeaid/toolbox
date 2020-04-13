defmodule Ferry.Profiles do
  @moduledoc """
  The Profiles context.
  """

  import Ecto
  import Ecto.Query, warn: false
  alias Ferry.Repo
  alias Ecto.Changeset

  @geocoder Application.get_env(:ferry, :geocoder)

  # Group
  # ==============================================================================
  alias Ferry.Profiles.Group

  @doc """
  Returns the list of groups.

  ## Examples

      iex> list_groups()
      [%Group{}, ...]

  """
  def list_groups() do
    Repo.all(Group)
  end

  def list_groups(preload: [:location]) do
    Repo.all(Group) |> Repo.preload([:location])
  end

  @doc """
  Gets a single group.

  Raises `Ecto.NoResultsError` if the Group does not exist.

  ## Examples

      iex> get_group!(123)
      %Group{}

      iex> get_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group!(id) do
    Repo.get!(Group, id)
  end

  def get_group(id) do
    Repo.get(Group, id)
  end

  def get_group(id, preload: [:location]) do
    query = from g in Group,
      join: a in assoc(g, :location),
      preload: [location: a]

    Repo.get(query, id)
  end

  def get_group_by_slug(slug) do
    Repo.get_by(Group, slug: slug)
  end

  @doc """
  Creates a group.

  ## Examples

      iex> create_group(%{field: value})
      {:ok, %Group{}}

      iex> create_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group(attrs \\ %{}) do
    %Group{}
    |> Group.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a group.

  ## Examples

      iex> update_group(group, %{field: new_value})
      {:ok, %Group{}}

      iex> update_group(group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group(%Group{} = group, attrs) do
    group
    |> Group.changeset(attrs)
    |> Group.logo_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Group.

  ## Examples

      iex> delete_group(group)
      {:ok, %Group{}}

      iex> delete_group(group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group(%Group{} = group) do
    Repo.delete(group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group changes.

  ## Examples

      iex> change_group(group)
      %Ecto.Changeset{source: %Group{}}

  """
  def change_group(%Group{} = group) do
    Group.changeset(group, %{})
  end

  # Project
  # ==============================================================================

  alias Ferry.Profiles.Project

  defp geocode_project_address(%Changeset{valid?: true} = changeset, address_attrs) do
    case @geocoder.geocode_address(changeset.params["address"]) do
      {:ok, geocode} ->
        attrs = %{"address" => Map.put(address_attrs, "geocode", geocode)}
        Project.address_changeset(changeset, attrs)

      {:error, _error} ->
        # TODO: proper error logging
        Changeset.add_error(
          changeset,
          :geocoding,
          "Our geocoding server sometimes can not locate a very specific address. Try removing your organization name, floor, or appartment # from the street line. If that continues to fail, try only city, country and postal code. If the problem persists, please reach out to us: help@distributeaid.org!"
        )
    end
  end

  defp geocode_project_address(%Changeset{valid?: false} = changeset, _address_attrs) do
    changeset
  end

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects()
      [%Project{}, ...]

  """
  def list_projects do
    Repo.all(
      from p in Project,
        left_join: g in assoc(p, :group),
        left_join: a in assoc(p, :address),
        preload: [group: g, address: a]
    )
  end

  @doc """
  Returns a list of projects for the specified group.

  ## Examples

      iex> list_projects(%Group{})
      [%Project{}, ...]

  """
  def list_projects(%Group{} = group) do
    Repo.all(
      from p in Project,
        where: p.group_id == ^group.id,
        left_join: a in assoc(p, :address),
        order_by: p.id,
        preload: [address: a]
    )
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(id) do
    query =
      from p in Project,
        left_join: a in assoc(p, :address),
        preload: [address: a]

    Repo.get!(query, id)
  end

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(%Group{}, %{field: value})
      {:ok, %Project{}}

      iex> create_project(%Group{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(%Group{} = group, attrs \\ %{}) do
    build_assoc(group, :projects)
    |> Project.changeset(attrs)
    |> geocode_project_address(attrs["address"])
    |> Repo.insert()
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Repo.preload(address: [:geocode])
    |> Project.changeset(attrs)
    |> geocode_project_address(attrs["address"])
    |> Repo.update()
  end

  @doc """
  Deletes a Project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{source: %Project{}}

  """
  def change_project(%Project{} = project) do
    Project.changeset(project, %{})
  end
end
