defmodule FerryApi.Schema.ModValueType do
  use Absinthe.Schema.Notation

  import AbsintheErrorPayload.Payload

  object :mod_value do
    field :id, non_null(:id)
    field :mod, non_null(:mod)
    field :value, non_null(:string)
  end

  payload_object(:mod_value_payload, :mod)
end
