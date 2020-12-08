defmodule FerryApi.Schema.UserType do
  use Absinthe.Schema.Notation
  import AbsintheErrorPayload.Payload

  object :user_group do
    field :id, non_null(:id)
    field :group, non_null(:group)
    field :user, non_null(:user)
    field :role, non_null(:string)
  end

  object :user do
    field :id, non_null(:id)
    field :email, non_null(:string)
    field :groups, list_of(:user_group)
  end

  payload_object(:user_payload, :user)
end
