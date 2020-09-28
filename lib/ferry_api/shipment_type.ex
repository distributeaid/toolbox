defmodule FerryApi.Schema.ShipmentType do
  use Absinthe.Schema.Notation

  import AbsintheErrorPayload.Payload

  object :shipment do
    field :id, non_null(:id)
    field :description, non_null(:string)
    field :status, non_null(:string)
    field :pickup_address, non_null(:string)
    field :delivery_address, non_null(:string)
    field :transport_type, non_null(:string)
    field :available_from, non_null(:datetime)
    field :target_delivery, non_null(:datetime)
  end

  payload_object(:shipment_payload, :shipment)
end
