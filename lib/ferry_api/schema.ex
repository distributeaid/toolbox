defmodule FerryApi.Schema do
  use Absinthe.Schema

  # Types
  # ------------------------------------------------------------

  import_types(Absinthe.Plug.Types)
  import_types(AbsintheErrorPayload.ValidationMessageTypes)

  import_types(FerryApi.Schema.GroupType)
  import_types(FerryApi.Schema.Group)

  import_types(FerryApi.Schema.SessionType)
  import_types(FerryApi.Schema.Session)

  import_types(FerryApi.Schema.SelfCare)

  # Queries
  # ------------------------------------------------------------

  query do
    import_fields(:group_queries)
    import_fields(:self_care_queries)
    import_fields(:session_queries)
  end

  # Mutuations
  # ------------------------------------------------------------

  mutation do
    import_fields(:group_mutations)
  end
end
