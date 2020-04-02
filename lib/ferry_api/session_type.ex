defmodule FerryApi.Schema.SessionType do
  use Absinthe.Schema.Notation

  object :session do
    field :user_id, :id
  end
end
