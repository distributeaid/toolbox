defmodule FerryApi.Schema do
  use Absinthe.Schema

  import_types(Absinthe.Plug.Types)
  import_types(Absinthe.Type.Custom)
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
  import_types(FerryApi.Schema.ModType)
  import_types(FerryApi.Schema.Mod)

  import_types(FerryApi.Schema.ModValueType)
  import_types(FerryApi.Schema.ModValue)

  import_types(FerryApi.Schema.ItemType)
  import_types(FerryApi.Schema.Item)

  import_types(FerryApi.Schema.ShipmentType)
  import_types(FerryApi.Schema.Shipment)

  import_types(FerryApi.Schema.PackageType)
  import_types(FerryApi.Schema.Package)

  import_types(FerryApi.Schema.ListType)
  import_types(FerryApi.Schema.EntryType)

  import_types(FerryApi.Schema.NeedsListType)
  import_types(FerryApi.Schema.NeedsList)

  import_types(FerryApi.Schema.ListEntryModValueType)
  import_types(FerryApi.Schema.ListEntryModValue)

  import_types(FerryApi.Schema.NeedsListEntryType)
  import_types(FerryApi.Schema.NeedsListEntry)

  import_types(FerryApi.Schema.AvailableListType)
  import_types(FerryApi.Schema.AvailableList)

  import_types(FerryApi.Schema.AvailableListEntryType)
  import_types(FerryApi.Schema.AvailableListEntry)

  import_types(FerryApi.Schema.ListEntryModValue)

  import_types(FerryApi.Schema.AvailableListEntryModValue)
  import_types(FerryApi.Schema.NeedsListEntryModValue)

  import_types(FerryApi.Schema.UserType)

  import_types(FerryApi.Schema.User)

  # Queries
  # ------------------------------------------------------------

  query do
    import_fields(:group_queries)
    import_fields(:project_queries)
    import_fields(:address_queries)
    import_fields(:self_care_queries)
    import_fields(:session_queries)
    import_fields(:category_queries)
    import_fields(:mod_queries)
    import_fields(:mod_value_queries)
    import_fields(:item_queries)
    import_fields(:shipment_queries)
    import_fields(:package_queries)
    import_fields(:needs_list_queries)
    import_fields(:needs_list_entry_queries)
    import_fields(:available_list_queries)
    import_fields(:available_list_entry_queries)
    import_fields(:user_queries)
  end

  # Mutuations
  # ------------------------------------------------------------

  mutation do
    import_fields(:group_mutations)
    import_fields(:project_mutations)
    import_fields(:address_mutations)
    import_fields(:category_mutations)
    import_fields(:mod_mutations)
    import_fields(:mod_value_mutations)
    import_fields(:item_mutations)
    import_fields(:shipment_mutations)
    import_fields(:package_mutations)
    import_fields(:needs_list_mutations)
    import_fields(:needs_list_entry_mutations)
    import_fields(:needs_list_entry_mod_value_mutations)
    import_fields(:available_list_mutations)
    import_fields(:available_list_entry_mutations)
    import_fields(:available_list_entry_mod_value_mutations)
    import_fields(:user_mutations)
  end

  @sources [
    # For now we have a single datasource
    # but in the future we could have one per
    # context
    FerryApi.Schema.Dataloader.Repo
  ]

  @doc """
  The context/1 function is a callback specified by
  the Absinthe.Schema behaviour that gives the schema
  itself an opportunity to set some values in the context
  that it may need in order to run.
  """
  @spec context(any()) :: map()
  def context(ctx) do
    # Add all sources to the dataloader and put
    # it in the context
    loader =
      Enum.reduce(@sources, Dataloader.new(), fn source, loader ->
        Dataloader.add_source(loader, source, source.data())
      end)

    Map.put(ctx, :loader, loader)
  end

  @doc """
  The plugins/0 function has been around for a while,
  and specifies what plugins the schema needs to resolve.

  See the documentation for more.
  """
  @spec plugins() :: [atom()]
  def plugins() do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
