defmodule FerryApi.Schema.ListType do
  use Absinthe.Schema.Notation

  object :list do
    field :id, non_null(:id)
  end
end
