defmodule Ferry.Schema do
  use Absinthe.Schema
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]


  # GROUPS
  # ================================================================================
  
  # Objects
  # ------------------------------------------------------------
  
  # object User do
  #   field :id, :id
  #   field :email, :string

  #   field :group, :group
  # end

  object :group do
    field :id, :id
    field :name, :string
    field :description, :string

    # field :logo, :file (?)

    # field :users, list_of(:user), resolve: dataloader(Ferry.Profiles.Group)
  end

  # Queries
  # ------------------------------------------------------------

  query do
    @desc "Health check"
    field :health_check, :string do
      resolve(fn _parent, _args, _resolution ->
        {:ok, "ok"}
      end)
    end

    @desc "Get all groups"
    field :groups, list_of(:group) do
      resolve &list_groups/3
    end

    @desc "Get a group"
    field :group, :group do
      arg :id, non_null(:id)
      resolve &get_group/3
    end
  end

  # Mutuations
  # ------------------------------------------------------------

  mutation do

    @desc "Create a group"
    field :create_group, type: :group do
      arg :name, non_null(:string)
      arg :description, non_null(:string)
      resolve &create_group/3
    end

  end




  # Resolvers
  # ------------------------------------------------------------

  def list_groups(_parent, _args, _resolution) do
    {:ok, Ferry.Profiles.list_groups()}
  end

  def get_group(_parent, %{id: id}, _resolution) do
    case Ferry.Profiles.get_group(id) do
      nil -> {:error, message: "Group not found.", id: id}
      group -> {:ok, group}
    end
  end

  def create_group(_parent, args, _resolution) do
    Ferry.Profiles.create_group(args)
  end

end
