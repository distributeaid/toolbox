defmodule FerryApi.Schema.EntryType do
  use Absinthe.Schema.Notation

  input_object :entry_input do
    field :list, non_null(:id)
    field :item, non_null(:id)
    field :amount, :integer
  end
end
