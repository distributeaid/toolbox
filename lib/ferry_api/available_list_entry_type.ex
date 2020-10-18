defmodule FerryApi.Schema.AvailableListEntryType do
  use Absinthe.Schema.Notation

  import AbsintheErrorPayload.Payload

  object :available_list_entry do
    field :id, non_null(:id)
    field :amount, :integer

    field :list, non_null(:available_list)
    field :item, non_null(:item)
    field :mod_values, list_of(:list_entry_mod_value)
  end

  payload_object(:available_list_entry_payload, :available_list_entry)
end
