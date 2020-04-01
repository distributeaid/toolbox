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

    import_fields :session_queries
  end

  # Mutuations
  # ------------------------------------------------------------

  mutation do

    import_fields :group_mutations

  end

end
