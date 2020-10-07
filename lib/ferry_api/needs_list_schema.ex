defmodule FerryApi.Schema.NeedsList do
  use Absinthe.Schema.Notation

  import AbsintheErrorPayload.Payload
  alias FerryApi.Middleware
  alias Ferry.Profiles
  alias Ferry.Aid

  object :needs_lists_queries do
  end

  input_object :needs_list_input do
    field :project, non_null(:id)
    field :from, non_null(:datetime)
    field :to, non_null(:datetime)
  end

  object :needs_lists_mutations do
    @desc "Create a needs list"
    field :create_needs_list, type: :needs_list_payload do
      arg(:needs_list_input, non_null(:needs_list_input))
      middleware(Middleware.RequireUser)
      resolve(&create_needs_list/3)
      middleware(&build_payload/2)
    end
  end

  @project_not_found "project not found"

  @doc """
  Graphql resolver that creates a needs list.

  We check that the project exists first
  """
  @spec create_needs_list(
          any,
          %{needs_list_input: map()},
          any
        ) :: {:error, Ecto.Changeset.t()} | {:ok, map()}
  def create_needs_list(
        _parent,
        %{needs_list_input: %{project: project} = attrs},
        _resolution
      ) do
    case Profiles.get_project(project) do
      nil ->
        {:error, @project_not_found}

      project ->
        Aid.create_needs_list(project, Map.drop(attrs, [:project]))
    end
  end
end
