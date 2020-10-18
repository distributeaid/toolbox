defmodule FerryApi.Schema.ListEntryModValue do
  use Absinthe.Schema.Notation

  input_object :entry_mod_value_input do
    field :entry, non_null(:id)
    field :mod_value, non_null(:id)
  end
end
