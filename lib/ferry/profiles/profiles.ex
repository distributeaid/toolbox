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
  alias Ferry.Locations.Address

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

  @doc """
  Returns a group, given its id
  """
  @spec get_group(String.t()) :: Group.t() | nil
  def get_group(id) do
    Group
    |> preload(addresses: [:project])
    |> preload(:projects)
    |> Repo.get(id)
  end

  @doc """
  Return a single group, given its slug
  """
  @spec get_group_by_slug(String.t()) :: {:ok, Group.t()} | :not_found
  def get_group_by_slug(slug) do
    case group_query(preload: [:addresses]) |> Repo.get_by(slug: slug) do
      nil ->
        :not_found

      group ->
        {:ok, group}
    end
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
  Deletes all groups
  """
  @spec delete_groups() :: boolean()
  def delete_groups() do
    Group
    |> Repo.delete_all()

    true
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
      if Enum.member?(preloads, :addresses) do
        from group in query,
          left_join: addresses in assoc(group, :addresses),
          preload: [addresses: addresses]
      else
        query
      end

    query
  end

  @spec setup_distributeaid() :: :ok
  @doc """
  Sets up the Distribute aid group. This is a well known
  group that we need in order to check
  for privileged access in account management.
  """
  def setup_distributeaid() do
    with {:ok, group} <-
           create_group(%{
             name: "DistributeAid",
             slug: "distributeaid",
             type: "M4D_CHAPTER",
             leader: "",
             description: "DistributeAid",
             donation_link: "https://request.example.com",
             slack_channel_name: "",
             request_form: "https://request.example.com",
             request_form_results: "https://request.example.com/results",
             volunteer_form: "https://volunteer.example.com",
             volunteer_form_results: "https://volunteer.example.com/results",
             donation_form: "https://donation.example.com",
             donation_form_results: "https://donation.example.com/results"
           }) do
      Ecto.Adapters.SQL.query(Repo, "UPDATE groups SET id = 0 WHERE id = $1", [group.id])
    end

    :ok
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
    Project
    |> Repo.get(id)
    |> Repo.preload(:group)
    |> Repo.preload(:addresses)
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
    with {:ok, project} <-
           build_assoc(group, :projects)
           |> Project.changeset(attrs)
           |> Repo.insert(),
         project when project != nil <- get_project(project.id) do
      {:ok, project}
    end
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

  @doc """
  Adds an address to a project
  """
  @spec add_address_to_project(Project.t(), Address.t()) ::
          {:ok, Project.t()} | {:error, Ecto.Changeset.t() | String.t()}
  def add_address_to_project(
        %Project{group: %{id: group_id}} = project,
        %Address{group: %{id: group_id}} = address
      ) do
    with {:ok, _} <- Ferry.Locations.update_address(address, %{project_id: project.id}) do
      {:ok, get_project(project.id)}
    end
  end

  def add_address_to_project(_project, _address) do
    {:error, "address does not belong to the project's group"}
  end

  @doc """
  Removes an address from a project
  """
  @spec remove_address_from_project(Project.t(), Address.t()) ::
          {:ok, Project.t()} | {:error, Ecto.Changeset.t()}
  def remove_address_from_project(%Project{} = project, %Address{} = address) do
    with {:ok, _} <- Ferry.Locations.update_address(address, %{project_id: nil}) do
      {:ok, get_project(project.id)}
    end
  end
end
