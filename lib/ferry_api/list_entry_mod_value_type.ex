defmodule FerryApi.Schema.ListEntryModValueType do
  use Absinthe.Schema.Notation

  object :list_entry_mod_value do
    field :id, non_null(:id)
    field :mod_value, non_null(:mod_value)
  end
end
