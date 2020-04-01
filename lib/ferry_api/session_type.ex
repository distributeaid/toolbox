defmodule FerryApi.Schema.SessionType do
  use Absinthe.Schema.Notation

  # TODO: move me to Schema.UserType
  object :user do
  end

  object :session do
    field :id, :id
    field :email_address, :string
  end
end
