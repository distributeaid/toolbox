defmodule FerryApi.Schema do
  use Absinthe.Schema

  # Types
  # ------------------------------------------------------------

  import_types(Absinthe.Plug.Types)
  import_types(AbsintheErrorPayload.ValidationMessageTypes)

  import_types(FerryApi.Schema.GroupType)
  import_types(FerryApi.Schema.Group)

  import_types(FerryApi.Schema.ProjectType)
  import_types(FerryApi.Schema.Project)

  import_types(FerryApi.Schema.AddressType)
  import_types(FerryApi.Schema.Address)

  import_types(FerryApi.Schema.SessionType)
  import_types(FerryApi.Schema.Session)

  import_types(FerryApi.Schema.SelfCare)

  import_types(FerryApi.Schema.CategoryType)
  import_types(FerryApi.Schema.Category)

  # Queries
  # ------------------------------------------------------------

  query do
    import_fields(:group_queries)
    import_fields(:project_queries)
    import_fields(:self_care_queries)
    import_fields(:session_queries)
    import_fields(:category_queries)
  end

  # Mutuations
  # ------------------------------------------------------------

  mutation do
    import_fields(:group_mutations)
    import_fields(:project_mutations)
    import_fields(:category_mutations)
  end
end
