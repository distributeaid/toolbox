defmodule FerryApi.Schema.Group do
  use Absinthe.Schema.Notation

  alias Ferry.Profiles

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
  end

  # Mutation
  # ------------------------------------------------------------
  object :group_mutations do
    @desc "Create a group"
    field :create_group, type: :group do
      arg(:name, non_null(:string))
      arg(:description, :string)
      arg(:slack_channel_name, non_null(:string))
      resolve(&create_group/3)
    end

    @desc "Update a group"
    field :update_group, type: :group do
      arg(:id, non_null(:id))
      arg(:description, :string)
      resolve(&update_group/3)
    end

    @desc "Delete a group"
    field :delete_group, type: :group do
      arg(:id, non_null(:id))
      resolve(&delete_group/3)
    end
  end

  # Resolvers
  # ------------------------------------------------------------
  def count_groups(_parent, _args, _resolution) do
    {:ok, length(Profiles.list_groups())}
  end

  def list_groups(_parent, _args, _resolution) do
    {:ok, Profiles.list_groups()}
  end

  def get_group(_parent, %{id: id}, _resolution) do
    case Profiles.get_group(id) do
      nil -> {:error, message: "Group not found.", id: id}
      group -> {:ok, group}
    end
  end

  def create_group(_parent, args, _resolution) do
    Profiles.create_group(args)
  end

  def update_group(_parent, %{id: id} = args, _resolution) do
    group = Profiles.get_group!(id)
    Profiles.update_group(group, args)
  end

  def delete_group(_parent, %{id: id}, _resolution) do
    group = Profiles.get_group!(id)
    Profiles.delete_group(group)
  end

end
