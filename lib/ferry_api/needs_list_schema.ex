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

    @desc "Update a needs list"
    field :update_needs_list, type: :needs_list_payload do
      arg(:id, non_null(:id))
      arg(:needs_list_input, non_null(:needs_list_input))
      middleware(Middleware.RequireUser)
      resolve(&update_needs_list/3)
      middleware(&build_payload/2)
    end
  end

  @project_not_found "project not found"
  @needs_list_not_found "needs list not found"

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

  @doc """
  Graphql resolver that updates a shipment.

  We check that both the pickup and delivery addresses do exit,
  before trying to create the shipment
  """
  @spec update_needs_list(
          any,
          %{id: integer(), needs_list_input: map()},
          any
        ) :: {:error, String.t()} | {:error, Ecto.Changeset.t()} | {:ok, map()}
  def update_needs_list(
        _parent,
        %{id: id, needs_list_input: %{project: project} = attrs},
        _resolution
      ) do
    case Aid.get_needs_list(id) do
      :not_found ->
        {:error, @needs_list_not_found}

      {:ok, needs_list} ->
        case Profiles.get_project(project) do
          nil ->
            {:error, @project_not_found}

          project ->
            Aid.update_needs_list(
              needs_list,
              project,
              Map.drop(attrs, [:project])
            )
        end
    end
  end
end
