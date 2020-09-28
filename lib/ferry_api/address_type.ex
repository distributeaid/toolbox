defmodule FerryApi.Schema.AddressType do
  use Absinthe.Schema.Notation
  import AbsintheErrorPayload.Payload

  object :address do
    field :id, non_null(:id)

    field :province, non_null(:string)
    field :country_code, non_null(:string)
    field :postal_code, non_null(:string)

    field :label, non_null(:string)
    field :street, non_null(:string)
    field :city, non_null(:string)

    field :group, non_null(:group)

    field :opening_hour, non_null(:string)
    field :closing_hour, non_null(:string)
    field :type, non_null(:string)
    field :has_loading_equipment, :boolean
    field :has_unloading_equipment, :boolean
    field :needs_appointment, :boolean
  end

  payload_object(:address_payload, :address)
end
