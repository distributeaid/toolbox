defmodule Ferry.Profiles do
  @moduledoc """
  The Profiles context.
  """

  import Ecto
  import Ecto.Query, warn: false
  alias Ferry.Repo

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
    query = group_query(preload: [])
    Repo.all(query)
  end

  def list_groups(preload: preload) do
    query = group_query(preload: preload)
    Repo.all(query)
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
    query = group_query(preload: [])
    Repo.get!(query, id)
  end

  def get_group(id) do
    query = group_query(preload: [])
    Repo.get(query, id)
  end

  def get_group(id, preload: preload) do
    query = group_query(preload: preload)
    Repo.get(query, id)
  end

  def get_group_by_slug(slug) do
    query = group_query(preload: [:location])
    Repo.get_by(query, slug: slug)
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

  # Helpers
  # ------------------------------------------------------------

  defp group_query(preload: preloads) do
    query =
      from group in Group,
        order_by: group.id

    query =
      if Enum.member?(preloads, :location) do
        from group in query,
          left_join: address in assoc(group, :location),
          preload: [location: address]
      else
        query
      end

    query
  end

  # Project
  # ==============================================================================

  alias Ferry.Profiles.Project

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects()
      [%Project{}, ...]

  """
  @spec list_projects() :: [Project.t()]
  def list_projects do
    Repo.all(
      from p in Project,
        left_join: g in assoc(p, :group),
        order_by: p.id
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
        order_by: p.id
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
  @spec get_project!(String.t()) :: Project.t()
  def get_project!(id) do
    Repo.get!(Project, id)
  end

  @doc """
  Gets a single project.

  Returns nil, if the project does not exist

  ## Examples

      iex> get_project(123)
      %Project{}

      iex> get_project(456)
      nil

  """
  @spec get_project(String.t()) :: Project.t() | nil
  def get_project(id) do
    Repo.get(Project, id)
  end

  @doc """
  Gets a single project by its name

  Returns nil, if the project does not exist

  ## Examples

      iex> get_project_by_name("test")
      %Project{}

      iex> get_project_by_name("unknown")
      nil

  """
  @spec get_project_by_name(String.t()) :: Project.t() | nil
  def get_project_by_name(name) do
    Repo.get_by(Project, name: name)
  end

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(%Group{}, %{field: value})
      {:ok, %Project{}}

      iex> create_project(%Group{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_project(Ferry.Profiles.Group.t(), map()) ::
          {:ok, Project.t()} | {:error, %Ecto.Changeset{}}
  def create_project(%Group{} = group, attrs \\ %{}) do
    build_assoc(group, :projects)
    |> Project.changeset(attrs)
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
  @spec update_project(Project.t(), map()) ::
          {:ok, Project.t()} | {:error, %Ecto.Changeset{}}
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
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
  @spec delete_project(Ferry.Profiles.Project.t()) :: Project.t()
  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end
end
