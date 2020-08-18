defmodule FerryApi.Schema.ItemType do
  use Absinthe.Schema.Notation

  import AbsintheErrorPayload.Payload

  object :item do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :category, non_null(:category)
  end

  payload_object(:item_payload, :project)
end
