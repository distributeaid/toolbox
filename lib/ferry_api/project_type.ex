defmodule FerryApi.Schema.ProjectType do
  use Absinthe.Schema.Notation

  import AbsintheErrorPayload.Payload

  object :project do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :description, non_null(:string)
    field :group, non_null(:group)
    field :addresses, list_of(:address)
  end

  payload_object(:project_payload, :project)
end
