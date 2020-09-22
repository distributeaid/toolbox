defmodule FerryApi.Schema.ModType do
  use Absinthe.Schema.Notation

  import AbsintheErrorPayload.Payload

  object :mod do
    # Required Fields
    # ------------------------------------------------------------
    field :id, non_null(:id)

    field :name, non_null(:string)
    field :description, non_null(:string)
    field :type, non_null(:string)
  end

  payload_object(:mod_payload, :mod)
end
