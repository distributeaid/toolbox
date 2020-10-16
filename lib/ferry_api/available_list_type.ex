defmodule FerryApi.Schema.AvailableListType do
  use Absinthe.Schema.Notation

  import AbsintheErrorPayload.Payload

  object :available_list do
    field :id, non_null(:id)
    field :at, non_null(:address)
    field :entries, list_of(:available_list_entry)
  end

  payload_object(:available_list_payload, :available_list)
end
