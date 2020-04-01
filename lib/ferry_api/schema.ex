defmodule FerryApi.Schema do
  use Absinthe.Schema
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  # Types
  # ------------------------------------------------------------

  import_types Absinthe.Plug.Types
  import_types FerryApi.Schema.ProfileTypes
  import_types FerryApi.Schema.SessionType


  # Queries
  # ------------------------------------------------------------

  query do

    @desc "Health check"
    field :health_check, :string do
      resolve(fn _parent, _args, _resolution ->
        {:ok, "ok"}
      end)
    end

    import_fields :group_queries

    @desc "Get current users session"
    field :session, :session do
      arg :access_token, non_null(:string)
      resolve &get_session/3
    end
  end

  # Mutuations
  # ------------------------------------------------------------

  mutation do

    import_fields :group_mutations

  end

  def get_session(_parent, %{access_token: access_token}, _resolution) do
    access_token
    |> Ferry.Cognito.get_user
    |> ExAws.request
    |> case do
      {:ok, _} -> {:ok, %{id: "me"}}
      _ -> {:error, message: "Invalid access token", code: "UNAUTHORIZED"}
    end
  end
end
