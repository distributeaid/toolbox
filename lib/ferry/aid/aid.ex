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
  alias Ferry.Aid.Entry
  alias Ferry.AidTaxonomy.Item
  alias Ferry.Profiles.Project

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
  @spec get_needs_list!(integer()) :: {:ok, NeedsList.t()} | :not_found
  def get_needs_list(id) do
    case NeedsList
         |> Repo.get(id)
         |> Repo.preload(project: :group)
         |> Repo.preload(
           entries: [
             item: [:mods, :category],
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

  @spec get_needs_list(Ferry.Profiles.Project.t(), Date.t()) :: any
  def get_needs_list(%Project{} = project, %Date{} = on) do
    query =
      from [needs_list, proj] in needs_list_query(),
        where:
          proj.id == ^project.id and
            needs_list.from <= ^on and
            needs_list.to >= ^on

    Repo.one(query)
  end

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
  @spec get_entries(NeedsList.t()) :: [Entry.t()]
  def get_entries(%NeedsList{} = needs) do
    with {:ok, list} <- aid_list_for(needs) do
      get_entries(list)
    end
  end

  def get_entries(%AidList{} = list) do
    list_id = list.id

    Entry
    |> where(list_id: ^list_id)
    |> Repo.all()
    |> Repo.preload(item: [:mods, :category])
    |> Repo.preload(list: [:needs_list, :available_list, :manifest_list])
  end

  @doc """
  Fetch a list entry given its id

  """
  @spec get_entry(String.t()) :: {:ok, Entry.t()} | :not_found
  def get_entry(id) do
    case Entry
         |> Repo.get(id)
         |> Repo.preload(item: [:mods, :category])
         |> Repo.preload(list: [:needs_list, :available_list, :manifest_list]) do
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
  @spec create_entry(AidList.t(), Item.t(), map()) ::
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
        IO.inspect(Repo.all(AidList))
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
end
