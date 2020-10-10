defmodule FerryApi.Schema.NeedsListType do
  use Absinthe.Schema.Notation

  import AbsintheErrorPayload.Payload

  object :needs_list do
    field :id, non_null(:id)
    field :from, non_null(:date)
    field :to, non_null(:date)

    field :project, non_null(:project)
  end

  payload_object(:needs_list_payload, :needs_list)
end
