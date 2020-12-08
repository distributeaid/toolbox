defmodule FerryApi.Schema.Group do
  use Absinthe.Schema.Notation

  import AbsintheErrorPayload.Payload

  alias Ferry.Profiles
  alias FerryApi.Middleware

  # Query
  # ------------------------------------------------------------
  object :group_queries do
    @desc "Get the # of groups"
    field :count_groups, :integer do
      resolve(&count_groups/3)
    end

    @desc "Get all groups"
    field :groups, list_of(:group) do
      resolve(&list_groups/3)
    end

    @desc "Get a group"
    field :group, :group do
      arg(:id, non_null(:id))
      resolve(&get_group/3)
    end

    @desc "Get a group by slug"
    field :group_by_slug, :group do
      arg(:slug, non_null(:string))
      resolve(&get_group_by_slug/3)
    end
  end

  # Mutation
  # ------------------------------------------------------------
  input_object :group_input do
    field :name, :string
    field :slug, :string
    # currently a constant on the backend "M4D_CHAPTER"
    field :type, :string

    field :leader, :string
    field :description, :string
    field :donation_link, :string
    field :slack_channel_name, :string

    field :request_form, :string
    field :request_form_results, :string
    field :volunteer_form, :string
    field :volunteer_form_results, :string
    field :donation_form, :string
    field :donation_form_results, :string
  end

  object :group_mutations do
    @desc "Create a group"
    field :create_group, type: :group_payload do
      arg(:group_input, non_null(:group_input))
      middleware(Middleware.RequireUser)
      resolve(&create_group/3)
      middleware(&build_payload/2)
    end

    @desc "Update a group"
    field :update_group, type: :group_payload do
      arg(:id, non_null(:id))
      arg(:group_input, non_null(:group_input))
      middleware(Middleware.RequireDaOrGroupAdmin)
      resolve(&update_group/3)
      middleware(&build_payload/2)
    end

    @desc "Delete a group"
    field :delete_group, type: :group_payload do
      arg(:id, non_null(:id))
      middleware(Middleware.RequireDaOrGroupAdmin)
      resolve(&delete_group/3)
      middleware(&build_payload/2)
    end
  end

  @group_not_found "group not found"
  @unauthorized "unauthorized"

  # Resolvers
  # ------------------------------------------------------------
  def count_groups(_parent, _args, _resolution) do
    {:ok, length(Profiles.list_groups())}
  end

  def list_groups(_parent, _args, _resolution) do
    {:ok, Profiles.list_groups(preload: [:addresses])}
  end

  def get_group(_parent, %{id: id}, _resolution) do
    with :not_found <- Profiles.get_group(id) do
      {:error, @group_not_found}
    end
  end

  def get_group_by_slug(_parent, %{slug: slug}, _resolution) do
    with :not_found <- Profiles.get_group_by_slug(slug) do
      {:error, @group_not_found}
    end
  end

  def create_group(_parent, %{group_input: group_attrs}, _resolution) do
    case Profiles.create_group(group_attrs) do
      {:ok, group} ->
        {:ok, %{group | addresses: []}}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def update_group(_parent, %{id: id, group_input: group_attrs}, _resolution) do
    case Profiles.get_group(id) do
      :not_found ->
        {:error, @group_not_found}

      {:ok, group} ->
        Profiles.update_group(group, group_attrs)
    end
  end

  def delete_group(_parent, %{id: id}, _resolution) do
    case Profiles.get_group(id) do
      :not_found ->
        {:error, @group_not_found}

      {:ok, %{id: 0}} ->
        # We can't really delete the Distribute Aid default group
        {:error, @unauthorized}

      {:ok, group} ->
        Profiles.delete_group(group)
    end
  end
end
