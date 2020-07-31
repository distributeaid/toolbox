defmodule FerryApi.Schema.ModType do
  use Absinthe.Schema.Notation

  import AbsintheErrorPayload.Payload

  object :mod do
    # Required Fields
    # ------------------------------------------------------------
    field :id, non_null(:id)

    # provided directly by user. e.g. Upper Manhatten, Whatcom County
    # validated for uniqueness
    # for now, collisions resolved manually E.g. "Manhatten (MT)"
    field :name, non_null(:string)
    field :description, non_null(:string)
    field :type, non_null(:string)
    field :values, list_of(:string)

    # TODO
    # field :items, list_of(:item), resolve: dataloader(Mod)
  end

  payload_object(:mod_payload, :mod)
end
