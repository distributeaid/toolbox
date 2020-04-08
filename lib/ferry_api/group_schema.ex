defmodule FerryApi.Schema.Group do
  use Absinthe.Schema.Notation

  alias Ferry.Profiles

  alias FerryApi.Schema.Constants

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
  input_object :group_input do
    field :name, :string
    # slug is generated from the name
    # currently a constant on the backend "M4D_CHAPTER"
    field :type

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
    field :create_group, type: :group do
      arg(:group_input, non_null(:group_input))
      resolve(&create_group/3)
    end

    @desc "Update a group"
    field :update_group, type: :group do
      arg(:id, non_null(:id))
      arg(:group_input, non_null(:group_input))
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

  def create_group(_parent, _args, %{context: %{user_id: nil}}) do
    {:error, message: "Not authorized", code: Constants.errors().unauthorized}
  end

  def create_group(_parent, %{group_input: group_attrs}, %{context: %{user_id: _user_id}}) do
    Profiles.create_group(group_attrs)
  end

  def update_group(_parent, %{id: id, group_input: group_attrs} = args, _resolution) do
    group = Profiles.get_group!(id)
    Profiles.update_group(group, group_attrs)
  end

  def delete_group(_parent, %{id: id}, _resolution) do
    group = Profiles.get_group!(id)
    Profiles.delete_group(group)
  end
end
