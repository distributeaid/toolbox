defmodule FerryApi.Schema.Address do
  use Absinthe.Schema.Notation

  # Query
  # ------------------------------------------------------------
  # TODO

  # Mutation
  # ------------------------------------------------------------
  input_object :address_input do
    field :province, :string
    field :country_code, :string
    field :postal_code, :string
  end

  # TODO: mutations

  # Resolvers
  # ------------------------------------------------------------
  # TODO

end
