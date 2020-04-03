defmodule FerryApi.Schema.GroupType do
  use Absinthe.Schema.Notation

  object :group do
    field :id, :id
    field :name, :string
    field :description, :string

    # field :logo, :file (?)

    # field :users, list_of(:user), resolve: dataloader(Group)
  end
end
