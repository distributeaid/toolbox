defmodule FerryApi.Schema.CategoryType do
  use Absinthe.Schema.Notation
  alias FerryApi.Schema.Dataloader.Repo
  import AbsintheErrorPayload.Payload
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  object :category do
    # Required Fields
    # ------------------------------------------------------------
    field :id, non_null(:id)

    # provided directly by user. e.g. Upper Manhatten, Whatcom County
    # validated for uniqueness
    # for now, collisions resolved manually E.g. "Manhatten (MT)"
    field :name, non_null(:string)

    field :items, list_of(:item), resolve: dataloader(Repo)
  end

  payload_object(:category_payload, :category)
end
