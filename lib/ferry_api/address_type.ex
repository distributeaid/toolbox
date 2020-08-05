defmodule FerryApi.Schema.AddressType do
  use Absinthe.Schema.Notation
  import AbsintheErrorPayload.Payload

  object :address do
    field :id, non_null(:id)

    field :province, non_null(:string)
    field :country_code, non_null(:string)
    field :postal_code, non_null(:string)

    field :label, :string
    field :street, :string
    field :city, :string

    field :group, non_null(:group)
  end

  payload_object(:address_payload, :address)
end
