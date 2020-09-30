defmodule FerryApi.Schema.PackageType do
  use Absinthe.Schema.Notation

  import AbsintheErrorPayload.Payload

  object :package do
    field :id, non_null(:id)
    field :shipment, non_null(:shipment)
    field :number, :integer
    field :type, non_null(:string)
    field :contents, non_null(:string)
    field :amount, :integer
    field :width, :integer
    field :height, :integer
    field :length, :integer
    field :stackable, :boolean
    field :dangerous_goods, :boolean
  end

  payload_object(:package_payload, :package)
end
