defmodule FerryApi.Schema.Session do
  use Absinthe.Schema.Notation

  object :session_queries do
    @desc "Get current users session"
    field :session, :session do
      resolve(&get_session/3)
    end
  end

  def get_session(_parent, _args, %{context: %{user_id: user_id}}) do
    {:ok, %{id: user_id}}
  end
end
