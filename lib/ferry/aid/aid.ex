defmodule Ferry.Aid do
  @moduledoc """
  The Aid context.

  This context focuses on actual representations of aid (available items, needs,
  shipment manifests, etc).  It uses the AidTaxonomy context in order to
  categorize and compare these representations.

  It takes a list-first approach:

    - TODO: describe what this means
  """
  import Ecto.Query, warn: false
  alias Ferry.Repo
  alias Ecto.Changeset

  alias Timex

  alias Ferry.Aid.AidList
  alias Ferry.Aid.NeedsList
  alias Ferry.Aid.AvailableList
  alias Ferry.Aid.Entry
  alias Ferry.Aid.EntryModValue
  alias Ferry.AidTaxonomy.Item
  alias Ferry.AidTaxonomy.ModValue
  alias Ferry.Profiles.Project
  alias Ferry.Locations.Address

  @doc """
  Return the aid list for the given id

  """
  @spec get_aid_list(String.t()) :: {:ok, AidList.t()} | :not_found
  def get_aid_list(id) do
    case AidList
         |> Repo.get(id) do
      nil ->
        :not_found

      list ->
        {:ok, list}
    end
  end

  # Needs List
  # ================================================================================
  # NOTE: The needs lists for a project shouldn't overlap.  In other words,
  #       a project should only have 1 needs list that spans a given day.
  #
  # TODO: how to add / update / delete entries? handle that generally w/ AidList functions?

  # Defaults to a 6 month duration (today => 6 months from now).
  #
  # Includes any needs list that overlaps with the duration (inclusive), even if
  # they begin or end outside of it.
  def list_needs_lists(%Project{} = project, %Date{} = from, %Date{} = to) do
    query =
      from [needs_list, proj] in needs_list_query(),
        where:
          proj.id == ^project.id and
            needs_list.from <= ^to and
            needs_list.to >= ^from

    Repo.all(query)
  end

  def list_needs_lists(%Project{} = project, %Date{} = from) do
    # TODO: probably want 5 months > end of month
    #       OR make from inclusive and to exclusive, ie [from, to)
    to = Timex.shift(from, months: 6)
    list_needs_lists(project, from, to)
  end

  def list_needs_lists(%Project{} = project) do
    list_needs_lists(project, Timex.today())
  end

  # TODO: useful to have project independent list_ functions?
  #       EX: list_needs_lists(%Date{} = from, %Date{} = to)
  #           list_needs_lists(%Date{} = on)
  #           list_current_needs_lists()
  #
  # TODO: or generalized ones with optional search parameters?
  #       EX: list_needs_lists(%{project, from, to, contains item, above/below amount, etc})

  # ------------------------------------------------------------

  def get_needs_list!(id) do
    needs_list_query()
    |> Repo.get!(id)
  end

  @doc """
  Return a needs list, given its id
  """
  @spec get_needs_list!(integer() | String.t()) :: {:ok, NeedsList.t()} | :not_found
  def get_needs_list(id) when is_binary(id) do
    id
    |> String.to_integer()
    |> get_needs_list()
  end

  def get_needs_list(id) when is_integer(id) do
    case NeedsList
         |> Repo.get(id)
         |> Repo.preload(project: :group)
         |> Repo.preload(:list)
         |> Repo.preload(
           entries: [
             item: [:mods, :category],
             mod_values: [mod_value: [:mod]],
             list: [:needs_list, :available_list, :manifest_list]
           ]
         ) do
      nil ->
        :not_found

      needs_list ->
        {:ok, needs_list}
    end
  end

  @doc """
  Returns the needs list for a given project and a given date
  """
  @spec get_needs_list(Ferry.Profiles.Project.t(), Date.t()) :: {:ok, %NeedsList{}} | :not_found
  def get_needs_list(%Project{} = project, %Date{} = on) do
    case from([needs_list, proj] in needs_list_query(),
           where:
             proj.id == ^project.id and
               needs_list.from <= ^on and
               needs_list.to >= ^on
         )
         |> Repo.one()
         |> Repo.preload(project: :group)
         |> Repo.preload(
           entries: [
             item: [:mods, :category],
             mod_values: [mod_value: [:mod]],
             list: [:needs_list, :available_list, :manifest_list]
           ]
         )
         |> Repo.preload(:list) do
      nil ->
        :not_found

      needs_list ->
        {:ok, needs_list}
    end
  end

  @doc """
  Return the needs list for the given project and the current date

  """
  @spec get_current_needs_list(Project.t()) :: {:ok, NeedsList.t()} | :not_found
  def get_current_needs_list(%Project{} = project) do
    # TODO: probably want to choose 'today' in the user's local timezone instead of utc
    get_needs_list(project, Timex.today())
  end

  # ------------------------------------------------------------

  @doc """
  Creates a new needs lists for the given project

  """
  @spec create_needs_list(
          Ferry.Profiles.Project.t(),
          map()
        ) :: {:ok, NeedsList.t()} | {:error, Ecto.Changeset}
  def create_needs_list(%Project{} = project, attrs \\ %{}) do
    with {:ok, needs_list} <-
           %NeedsList{project_id: project.id}
           |> NeedsList.changeset(attrs, &has_overlap?/1)
           |> Changeset.put_assoc(:list, %AidList{entries: []})
           |> Repo.insert() do
      get_needs_list(needs_list.id)
    end
  end

  @doc """
  Updates the given needs list, by setting it in the
  given project with the given attributes
  """
  @spec update_needs_list(NeedsList.t(), Project.t(), map()) ::
          {:ok, NeedsList.t()} | {:error, Ecto.Changeset}
  def update_needs_list(%NeedsList{} = list, %Project{} = project, attrs) do
    attrs = Map.put(attrs, :project_id, project.id)

    with {:ok, needs_list} <-
           list
           |> NeedsList.changeset(attrs, &has_overlap?/1)
           |> Repo.update() do
      get_needs_list(needs_list.id)
    end
  end

  def update_needs_list(%NeedsList{} = list, attrs) do
    list
    |> NeedsList.changeset(attrs, &has_overlap?/1)
    |> Repo.update()
  end

  def delete_needs_list(%NeedsList{} = list) do
    list
    # TODO: maybe run the changeset to handle db constraint errors
    |> Repo.delete()
  end

  # ------------------------------------------------------------

  def change_needs_list(%NeedsList{} = list) do
    NeedsList.changeset(list, %{}, fn _ -> false end)
  end

  # Helpers
  # ------------------------------------------------------------

  # TODO: include .list field in preloads?
  defp needs_list_query() do
    from needs_list in NeedsList,
      join: project in assoc(needs_list, :project),
      join: group in assoc(project, :group),
      left_join: entries in assoc(needs_list, :entries),
      order_by: needs_list.from,
      preload: [
        project: {project, group: group},
        entries: entries
      ]
  end

  defp has_overlap?(%NeedsList{} = needs) do
    query =
      from needs_list in NeedsList,
        where:
          needs_list.project_id == ^needs.project_id and
            needs_list.from <= ^needs.to and
            needs_list.to >= ^needs.from

    # if the needs list has an id (exists in the DB), then don't check it
    # against itself for an overlap
    query =
      if needs.id == nil do
        query
      else
        from [needs_list] in query,
          where: needs_list.id != ^needs.id
      end

    Repo.exists?(query)
  end

  @doc """
  Returns an available list given its id
  """
  @spec get_available_list(integer()) :: {:ok, AvailableList.t()} | :not_found
  def get_available_list(id) do
    case AvailableList
         |> Repo.get(id)
         |> Repo.preload(at: [:project, :group])
         |> Repo.preload(
           entries: [
             item: [:mods, :category],
             mod_values: [mod_value: [:mod]],
             list: [:needs_list, :available_list, :manifest_list]
           ]
         )
         |> Repo.preload(:list) do
      nil ->
        :not_found

      available_list ->
        {:ok, available_list}
    end
  end

  @doc """
  Returns all available lists for a given address
  """
  @spec get_available_lists(Address.t()) :: [AvailableList.t()]
  def get_available_lists(address) do
    address_id = address.id

    from(available_list in AvailableList,
      where: available_list.address_id == ^address_id
    )
    |> Repo.all()
    |> Repo.preload(at: [:project, :group])
    |> Repo.preload(
      entries: [
        item: [:mods, :category],
        mod_values: [mod_value: [:mod]],
        list: [:needs_list, :available_list, :manifest_list]
      ]
    )
    |> Repo.preload(:list)
  end

  @doc """
  Creates a new available list for the given address
  """
  @spec create_available_list(Address.t(), map()) ::
          {:ok, AvailableList.t()} | {:error, Ecto.Changeset.t()}
  def create_available_list(address, attrs \\ %{}) do
    attrs =
      attrs
      |> Map.put(:address_id, address.id)

    with {:ok, available_list} <-
           %AvailableList{}
           |> AvailableList.create_changeset(attrs)
           |> Changeset.put_assoc(:list, %AidList{entries: []})
           |> Repo.insert() do
      get_available_list(available_list.id)
    end
  end

  @doc """
  Deletes an available list.

  If the list has entries, they will also be deleted
  """
  @spec delete_available_list(AvailableList.t()) ::
          {:ok, AvailableList.t()} | {:error, Ecto.Changeset.t()}
  def delete_available_list(%AvailableList{} = list) do
    list
    |> Repo.delete()
  end

  @doc """
  Counts all entries in the database
  """
  @spec count_entries() :: integer()
  def count_entries() do
    Entry
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Returns all entries for a list. A list can be either
  a needs list, available list or a manifest list
  """
  @spec get_entries(NeedsList.t() | AvailableList.t()) :: [Entry.t()]
  def get_entries(%NeedsList{} = needs) do
    with {:ok, list} <- aid_list_for(needs) do
      get_entries(list)
    end
  end

  def get_entries(%AvailableList{} = available) do
    with {:ok, list} <- aid_list_for(available) do
      get_entries(list)
    end
  end

  def get_entries(%AidList{} = list) do
    list_id = list.id

    Entry
    |> where(list_id: ^list_id)
    |> Repo.all()
    |> Repo.preload(item: [:mods, :category])
    |> Repo.preload(mod_values: [mod_value: [:mod]])
    |> Repo.preload(list: [:needs_list, :available_list, :manifest_list])
  end

  @doc """
  Fetch a list entry given its id.any()

  This function offers some flexibility in the way mod_values are preloaded, via opts:

  *  setting `item_preload` to `with_mod_values` will preload the entry's item mods, and for
     each mod, it will also preload all mod_values. Otherwise, only the mod is pre-loaded.

  """
  @spec get_entry(String.t(), Keyword.t()) :: {:ok, Entry.t()} | :not_found
  def get_entry(id, opts \\ []) do
    # Choose whether we want to preload all mod_values for each
    # mod associated to the entry via its item mod_values
    item_preload =
      case opts[:item_preload] do
        :with_mod_values ->
          [mods: [:values], category: []]

        _ ->
          [:mods, :category]
      end

    case Entry
         |> Repo.get(id)
         |> Repo.preload(item: item_preload)
         |> Repo.preload(list: [:needs_list, :available_list, :manifest_list])
         |> Repo.preload(mod_values: [mod_value: [:mod]]) do
      nil ->
        :not_found

      entry ->
        {:ok, entry}
    end
  end

  @doc """
  Creates a new entry for the given item and the given
  list. A list can be either a needs list, an availability list
  or a manifest list
  """
  @spec create_entry(AidList.t() | NeedsList.t() | AvailableList.t(), Item.t(), map()) ::
          {:ok, Entry.t()} | {:error, Ecto.Changeset.t()}
  def create_entry(%AidList{} = list, %Item{} = item, attrs) do
    attrs =
      attrs
      |> Map.put(:item_id, item.id)
      |> Map.put(:list_id, list.id)

    with {:ok, entry} <-
           %Entry{}
           |> Entry.create_changeset(attrs)
           |> Repo.insert() do
      get_entry(entry.id)
    end
  end

  def create_entry(%NeedsList{} = list, %Item{} = item, attrs) do
    with {:ok, list} <- aid_list_for(list) do
      create_entry(list, item, attrs)
    end
  end

  def create_entry(%AvailableList{} = list, %Item{} = item, attrs) do
    with {:ok, list} <- aid_list_for(list) do
      create_entry(list, item, attrs)
    end
  end

  @doc """
  Updates a list entry.

  """
  @spec update_entry(Entry.t(), map()) :: {:ok, Entry.t()} | {:error, Ecto.Changeset.t()}
  def update_entry(entry, attrs) do
    with {:ok, entry} <-
           entry
           |> Entry.update_changeset(attrs)
           |> Repo.update() do
      get_entry(entry.id)
    end
  end

  # Find the aid list for the given concrete list
  defp aid_list_for(%NeedsList{id: id}) do
    case Repo.get_by(AidList, needs_list_id: id) do
      nil ->
        :not_found

      list ->
        {:ok, list}
    end
  end

  defp aid_list_for(%AvailableList{id: id}) do
    case Repo.get_by(AidList, available_list_id: id) do
      nil ->
        :not_found

      list ->
        {:ok, list}
    end
  end

  @doc """
  Delete a list entry
  """
  @spec delete_entry(Entry.t()) :: {:ok, Entry.t()} | {:error, Ecto.Changeset}
  def delete_entry(entry) do
    entry
    |> Entry.delete_changeset()
    |> Repo.delete()
  end

  @doc """
  Counts all mod values associated to existing list entries

  """
  @spec count_entry_mod_values() :: integer()
  def count_entry_mod_values() do
    EntryModValue
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Adds the given mod value to the given list entry
  """
  @spec add_mod_value_to_entry(ModValue.t(), Entry.t()) :: :ok | {:error, Ecto.Changeset.t()}
  def add_mod_value_to_entry(%ModValue{} = mod_value, %Entry{} = entry) do
    with {:ok, _} <-
           %EntryModValue{}
           |> EntryModValue.changeset(%{entry_id: entry.id, mod_value_id: mod_value.id})
           |> Repo.insert() do
      :ok
    end
  end

  @doc """
  Removes the given mod_value from the given list entry
  """
  @spec remove_mod_value_from_entry(ModValue.t(), Entry.t()) :: :ok | {:error, Ecto.Changeset.t()}
  def remove_mod_value_from_entry(%ModValue{} = mod_value, %Entry{} = entry) do
    mod_value_id = mod_value.id
    entry_id = entry.id

    with {_, nil} <-
           from(v in EntryModValue,
             where: v.mod_value_id == ^mod_value_id and v.entry_id == ^entry_id
           )
           |> Repo.delete_all() do
      :ok
    end
  end

  @doc """
  Given a list of addresses, this function builds the aggregated needs
  of all projects related to any of those addresses, for the current date.

  It is required that each address provided in the list has its project
  preloaded.
  """
  @spec get_current_needs_list_by_addresses([Address.t()]) :: {:ok, NeedsList.t()}
  def get_current_needs_list_by_addresses(addresses) do
    {:ok,
     addresses
     |> Enum.map(fn %Address{project: project} -> project end)
     |> resolve_aggregate_needs_lists(fn project ->
       get_current_needs_list(project)
     end)}
  end

  # Generic function that performs the aggregation of all
  # needs lists found for the given projects. It uses the specified
  # resolver function in order to convert a project to
  # into a needs list. If the resolver function does not return
  # any needs list, then the project will simply be ignored
  defp resolve_aggregate_needs_lists(projects, resolver_fn) do
    Enum.reduce(projects, %NeedsList{entries: []}, fn
      %Project{id: _} = project, acc_needs_list ->
        case resolver_fn.(project) do
          :not_found ->
            acc_needs_list

          {:ok, needs_list} ->
            aggregated_needs_list(needs_list, acc_needs_list)
        end

      # if the given project is not a valid project
      # then simply skip it
      _, acc_needs_list ->
        acc_needs_list
    end)
  end

  @doc """
  Aggregates the given `source` needs list, into the `target`
  needs list
  """
  @spec aggregated_needs_list(NeedsList.t(), NeedsList.t()) :: NeedsList.t()
  def aggregated_needs_list(
        %NeedsList{entries: source_entries},
        target
      ) do
    Enum.reduce(source_entries, target, fn entry, target ->
      aggregated_needs_entry(entry, target)
    end)
  end

  # Aggregates the given entry in the given needs list. If the
  # entry matches an existing one, then increment the count. Otherwise
  # add the entry to the list
  defp aggregated_needs_entry(entry, %NeedsList{entries: entries} = target) do
    {entries, found} =
      Enum.map_reduce(entries, false, fn
        existing, true ->
          {existing, true}

        existing, false ->
          case Entry.eq?(existing, entry) do
            true ->
              {%{existing | amount: existing.amount + entry.amount}, true}

            false ->
              {existing, false}
          end
      end)

    entries =
      case found do
        true ->
          entries

        false ->
          [entry | entries]
      end

    %{target | entries: entries}
  end
end
