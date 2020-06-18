defmodule FerryApi.Schema.AddressType do
  use Absinthe.Schema.Notation

  object :address do
    # Required Fields
    # ------------------------------------------------------------
    field :id, non_null(:id)

    field :province, non_null(:string)
    field :country_code, non_null(:string)
    field :postal_code, non_null(:string)

    # Optional Fields
    # ------------------------------------------------------------

    field :label, :string
    field :street, :string
    field :city, :string

    # Relations
    # ------------------------------------------------------------

    # TODO
    # field :group
  end

  #  payload_object(:address_payload, :address)
end
