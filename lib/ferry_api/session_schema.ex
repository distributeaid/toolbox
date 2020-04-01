defmodule FerryApi.Schema.Session do
  use Absinthe.Schema.Notation
  alias FerryApi.Schema.Constants

  object :session_queries do
    @desc "Get current users session"
    field :session, :session do
      arg :access_token, non_null(:string)
      resolve &get_session/3
    end
  end

  def get_session(_parent, %{access_token: access_token}, _resolution) do
    access_token
    |> Ferry.Cognito.get_user
    |> ExAws.request
    |> case do
      {:ok, _} -> {:ok, %{id: "me"}}
      _ -> {:error, message: "Invalid access token", code: Constants.errors.unauthorized}
    end
  end
end
