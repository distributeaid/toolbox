defmodule FerryApi.Schema.SessionGraph do
  use Absinthe.Schema.Notation

  object :session_queries do
    @desc "Get the # of groups"
    field :session, :session do
      arg :access_token, non_null(:string)
      resolve &get_session/3
    end
  end

  # Resolvers
  # ------------------------------------------------------------
  def get_session(_parent, _args, _resolution) do
    {:ok, %{id: "me", email_address: "foo@bar.com"}}
  end
end
