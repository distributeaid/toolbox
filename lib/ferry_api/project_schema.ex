defmodule FerryApi.Schema.Project do
  use Absinthe.Schema.Notation

  import AbsintheErrorPayload.Payload
  alias FerryApi.Middleware

  object :project_queries do
    @desc "Get the # of projects"
    field :count_projects, :integer do
      resolve(&count_projects/3)
    end

    @desc "Get all projects"
    field :projects, list_of(:project) do
      resolve(&list_projects/3)
    end

    @desc "Get a project"
    field :project, :project do
      arg(:id, non_null(:id))
      resolve(&get_project/3)
    end

    @desc "Get a project by name"
    field :project_by_name, :project do
      arg(:name, non_null(:string))
      resolve(&get_project_by_name/3)
    end
  end

  input_object :project_input do
    field :name, :string
    field :description, :string
    field :group, :id
  end

  object :project_mutations do
    @desc "Create a project"
    field :create_project, type: :project_payload do
      arg(:project_input, non_null(:project_input))
      middleware(Middleware.RequireUser)
      resolve(&create_project/3)
      middleware(&build_payload/2)
    end

    @desc "Update a project"
    field :update_project, type: :project_payload do
      arg(:id, non_null(:id))
      arg(:project_input, non_null(:project_input))
      middleware(Middleware.RequireUser)
      resolve(&update_project/3)
      middleware(&build_payload/2)
    end

    @desc "Delete a project"
    field :delete_project, type: :project_payload do
      arg(:id, non_null(:id))
      middleware(Middleware.RequireUser)
      resolve(&delete_project/3)
      middleware(&build_payload/2)
    end
  end

  @project_not_found "project not found"
  @group_not_found "group not found"

  @doc """
  Graphql resolver that returns the total number of projects
  """
  @spec count_projects(map(), map(), Absinthe.Resolution.t()) :: {:ok, non_neg_integer()}
  def count_projects(_parent, _args, _resolution) do
    {:ok, length(Ferry.Profiles.list_projects())}
  end

  @doc """
  Graphql resolver that returns a collection of entities
  """
  @spec list_projects(map(), map(), Absinthe.Resolution.t()) ::
          {:ok, [Ferry.Profiles.Project.t()]}
  def list_projects(_parent, _args, _resolution) do
    {:ok, Ferry.Profiles.list_projects()}
  end

  @doc """
  Graphql resolver that returns a single project, given its id
  """
  @spec get_project(any, %{id: integer}, any) ::
          {:error, String.t()} | {:ok, Ferry.Profiles.Project.t()}
  def get_project(_parent, %{id: id}, _resolution) do
    case Ferry.Profiles.get_project(id) do
      nil ->
        {:error, @project_not_found}

      project ->
        {:ok, project}
    end
  end

  @doc """
  Graphql resolver that returns a single project, given its name
  """
  @spec get_project_by_name(any, %{name: binary}, any) ::
          {:error, String.t()} | {:ok, Ferry.Profiles.Project.t()}
  def get_project_by_name(_parent, %{name: name}, _resolution) do
    case Ferry.Profiles.get_project_by_name(name) do
      nil ->
        {:error, @project_not_found}

      project ->
        {:ok, project}
    end
  end

  @doc """
  Graphql resolver that creates a project for a given group

  If the group does not exist, then an error is returned.
  """
  @spec create_project(
          any,
          %{project_input: map()},
          any
        ) :: {:error, Ecto.Changeset.t()} | {:ok, Ferry.Profiles.Project.t()}
  def create_project(_parent, %{project_input: project_attrs}, _resolution) do
    case Ferry.Profiles.get_group(project_attrs.group) do
      nil ->
        {:error, @group_not_found}

      group ->
        Ferry.Profiles.create_project(group, project_attrs)
    end
  end

  @doc """
  Graphql resolver that updates an existing project
  """
  @spec update_project(any, %{project_input: any, id: integer}, any) ::
          {:error, String.t() | Ecto.Changeset.t()} | {:ok, Ferry.Profiles.Project.t()}
  def update_project(_parent, %{id: id, project_input: project_attrs}, _resolution) do
    case Ferry.Profiles.get_project(id) do
      nil ->
        {:error, @project_not_found}

      project ->
        Ferry.Profiles.update_project(project, project_attrs)
    end
  end

  @doc """
  Graphql resolver that deletes an existing project
  """
  @spec delete_project(any, %{id: integer}, any) ::
          {:error, String.t() | Ecto.Changeset.t()} | {:ok, Ferry.Profiles.Project.t()}
  def delete_project(_parent, %{id: id}, _resolution) do
    case Ferry.Profiles.get_project(id) do
      nil -> {:error, @project_not_found}
      project -> Ferry.Profiles.delete_project(project)
    end
  end
end
