defmodule FerryApi.Schema.ModType do
  use Absinthe.Schema.Notation
  alias FerryApi.Schema.Dataloader.Repo
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  import AbsintheErrorPayload.Payload

  object :mod do
    # Required Fields
    # ------------------------------------------------------------
    field :id, non_null(:id)

    field :name, non_null(:string)
    field :description, non_null(:string)
    field :type, non_null(:string)

    field :values, list_of(:mod_value), resolve: dataloader(Repo)
  end

  payload_object(:mod_payload, :mod)
end
