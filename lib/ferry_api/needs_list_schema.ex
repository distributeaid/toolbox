defmodule FerryApi.Schema.NeedsList do
  use Absinthe.Schema.Notation

  import AbsintheErrorPayload.Payload
  alias FerryApi.Middleware
  alias Ferry.Profiles
  alias Ferry.Aid

  object :needs_list_queries do
    @desc "Returns a single needs list"
    field :needs_list, :needs_list do
      arg(:id, non_null(:id))
      resolve(&needs_list/3)
    end

    @desc "Returns all needs lists for a project that fall within the given date range"
    field :needs_lists, list_of(:needs_list) do
      arg(:project, non_null(:id))
      arg(:from, non_null(:datetime))
      arg(:to, non_null(:datetime))
      resolve(&project_needs_lists/3)
    end

    @desc "Returns current's needs list for a project"
    field :current_needs_list, :needs_list do
      arg(:project, non_null(:id))
      resolve(&project_current_needs_list/3)
    end

    @desc "Returns an aggregated current's needs list for a list of addresses"
    field :current_needs_list_by_addresses, :needs_list do
      arg(:addresses, list_of(:id))
      resolve(&current_needs_list_by_addresses/3)
    end

    @desc "Returns an aggregated needs list for a list of addresses and a date range"
    field :needs_list_by_addresses, :needs_list do
      arg(:addresses, list_of(:id))
      arg(:from, non_null(:datetime))
      arg(:to, non_null(:datetime))
      resolve(&needs_list_by_addresses/3)
    end

    @desc "Returns an aggregated current's needs list for a list of groups"
    field :current_needs_list_by_groups, :needs_list do
      arg(:groups, list_of(:id))
      resolve(&current_needs_list_by_groups/3)
    end

    @desc "Returns an aggregated needs list for a list of groups and a date range"
    field :needs_list_by_groups, :needs_list do
      arg(:groups, list_of(:id))
      arg(:from, non_null(:datetime))
      arg(:to, non_null(:datetime))
      resolve(&needs_list_by_groups/3)
    end

    @desc "Returns an aggregated current's needs list for a list of postal codes"
    field :current_needs_list_by_postal_codes, :needs_list do
      arg(:postal_codes, list_of(:string))
      resolve(&current_needs_list_by_postal_codes/3)
    end

    @desc "Returns an aggregated needs list for a list of postal codes and a date range"
    field :needs_list_by_postal_codes, :needs_list do
      arg(:postal_codes, list_of(:string))
      arg(:from, non_null(:datetime))
      arg(:to, non_null(:datetime))
      resolve(&needs_list_by_postal_codes/3)
    end
  end

  input_object :needs_list_input do
    field :project, non_null(:id)
    field :from, non_null(:datetime)
    field :to, non_null(:datetime)
  end

  object :needs_list_mutations do
    @desc "Create a needs list"
    field :create_needs_list, type: :needs_list_payload do
      arg(:needs_list_input, non_null(:needs_list_input))
      middleware(Middleware.RequireUser)
      resolve(&create_needs_list/3)
      middleware(&build_payload/2)
    end

    @desc "Update a needs list"
    field :update_needs_list, type: :needs_list_payload do
      arg(:id, non_null(:id))
      arg(:needs_list_input, non_null(:needs_list_input))
      middleware(Middleware.RequireUser)
      resolve(&update_needs_list/3)
      middleware(&build_payload/2)
    end

    @desc "Delete a needs list"
    field :delete_needs_list, type: :needs_list_payload do
      arg(:id, non_null(:id))
      middleware(Middleware.RequireUser)
      resolve(&delete_needs_list/3)
      middleware(&build_payload/2)
    end
  end

  @project_not_found "project not found"
  @needs_list_not_found "needs list not found"

  @doc """
  Returns the current needs list for a project

  """
  @spec needs_list(any(), %{id: String.t()}, any()) ::
          {:ok, [map()]} | {:error, term()}
  def needs_list(_, %{id: id}, _) do
    with :not_found <- Aid.get_needs_list(id) do
      {:error, @needs_list_not_found}
    end
  end

  @doc """
  Returns the current needs list for a project

  """
  @spec project_current_needs_list(any(), %{project: String.t()}, any()) ::
          {:ok, map()} | {:error, term()}
  def project_current_needs_list(_, %{project: id}, _) do
    case Profiles.get_project(id) do
      nil ->
        {:error, @project_not_found}

      project ->
        with :not_found <- Aid.get_current_needs_list(project) do
          {:error, @needs_list_not_found}
        end
    end
  end

  @doc """
  Returns all needs lists for the given project
  that fall within the given date range

  """
  @spec project_needs_lists(any(), %{project: String.t(), from: Date.t(), to: Date.t()}, any()) ::
          {:ok, [map()]} | {:error, term()}
  def project_needs_lists(_, %{project: id, from: from, to: to}, _) do
    case Profiles.get_project(id) do
      nil ->
        {:error, @project_not_found}

      project ->
        Aid.get_needs_lists(project, DateTime.to_date(from), DateTime.to_date(to))
    end
  end

  @doc """
  Resolver that returns an aggregated needs list for all addresses found for the given
  ids. If an id can't be resolve to a valid address, it will be ignored.
  """
  @spec current_needs_list_by_addresses(any(), %{addresses: [String.t()]}, any()) ::
          {:ok, map()} | {:error, term()}
  def current_needs_list_by_addresses(_, %{addresses: ids}, _) do
    ids
    |> Enum.map(&Ferry.Locations.get_address(&1))
    |> Enum.filter(fn addr -> addr != nil end)
    |> Aid.get_current_needs_list_by_addresses()
  end

  @doc """
  Resolver that returns an aggregated needs list for all addresses found for the given
  ids. If an id can't be resolve to a valid address, it will be ignored.
  """
  @spec needs_list_by_addresses(
          any(),
          %{addresses: [String.t()], from: DateTime.t(), to: DateTime.t()},
          any()
        ) ::
          {:ok, map()} | {:error, term()}
  def needs_list_by_addresses(_, %{addresses: ids, from: from, to: to}, _) do
    ids
    |> Enum.map(&Ferry.Locations.get_address(&1))
    |> Enum.filter(fn addr -> addr != nil end)
    |> Aid.get_needs_list_by_addresses(DateTime.to_date(from), DateTime.to_date(to))
  end

  @doc """
  Resolver that returns an aggregated needs list for all groups found for the given
  ids. If an id can't be resolve to a valid group, it will be ignored.
  """
  @spec current_needs_list_by_groups(any(), %{groups: [String.t()]}, any()) ::
          {:ok, map()} | {:error, term()}
  def current_needs_list_by_groups(_, %{groups: ids}, _) do
    ids
    |> Enum.map(&Ferry.Profiles.get_group(&1))
    |> Enum.filter(fn group -> group != nil end)
    |> Enum.flat_map(fn group -> group.addresses end)
    |> Aid.get_current_needs_list_by_addresses()
  end

  @doc """
  Resolver that returns an aggregated needs list for all groups found for the given
  ids. If an id can't be resolve to a valid group, it will be ignored.
  """
  @spec needs_list_by_groups(
          any(),
          %{groups: [String.t()], from: DateTime.t(), to: DateTime.t()},
          any()
        ) ::
          {:ok, map()} | {:error, term()}
  def needs_list_by_groups(_, %{groups: ids, from: from, to: to}, _) do
    ids
    |> Enum.map(&Ferry.Profiles.get_group(&1))
    |> Enum.filter(fn group -> group != nil end)
    |> Enum.flat_map(fn group -> group.addresses end)
    |> Aid.get_needs_list_by_addresses(DateTime.to_date(from), DateTime.to_date(to))
  end

  @doc """
  Resolver that returns an aggregated needs list for all addresses found for the given
  postal codes.
  """
  @spec current_needs_list_by_postal_codes(any(), %{postal_codes: [String.t()]}, any()) ::
          {:ok, map()} | {:error, term()}
  def current_needs_list_by_postal_codes(_, %{postal_codes: codes}, _) do
    codes
    |> Ferry.Locations.get_addresses_by_postal_codes()
    |> Aid.get_current_needs_list_by_addresses()
  end

  @doc """
  Resolver that returns an aggregated needs list for all addresses found for the given
  postal codes.
  """
  @spec needs_list_by_postal_codes(
          any(),
          %{postal_codes: [String.t()], from: DateTime.t(), to: DateTime.t()},
          any()
        ) ::
          {:ok, map()} | {:error, term()}
  def needs_list_by_postal_codes(_, %{postal_codes: codes, from: from, to: to}, _) do
    codes
    |> Ferry.Locations.get_addresses_by_postal_codes()
    |> Aid.get_needs_list_by_addresses(DateTime.to_date(from), DateTime.to_date(to))
  end

  @doc """
  Graphql resolver that creates a needs list.

  We check that the project exists first
  """
  @spec create_needs_list(
          any,
          %{needs_list_input: map()},
          any
        ) :: {:error, Ecto.Changeset.t()} | {:ok, map()}
  def create_needs_list(
        _parent,
        %{needs_list_input: %{project: project} = attrs},
        _resolution
      ) do
    case Profiles.get_project(project) do
      nil ->
        {:error, @project_not_found}

      project ->
        Aid.create_needs_list(project, Map.drop(attrs, [:project]))
    end
  end

  @doc """
  Graphql resolver that updates a shipment.

  We check that both the pickup and delivery addresses do exit,
  before trying to create the shipment
  """
  @spec update_needs_list(
          any,
          %{id: integer(), needs_list_input: map()},
          any
        ) :: {:error, String.t()} | {:error, Ecto.Changeset.t()} | {:ok, map()}
  def update_needs_list(
        _parent,
        %{id: id, needs_list_input: %{project: project} = attrs},
        _resolution
      ) do
    case Aid.get_needs_list(id) do
      :not_found ->
        {:error, @needs_list_not_found}

      {:ok, needs_list} ->
        case Profiles.get_project(project) do
          nil ->
            {:error, @project_not_found}

          project ->
            Aid.update_needs_list(
              needs_list,
              project,
              Map.drop(attrs, [:project])
            )
        end
    end
  end

  @doc """
  Deletes a needs list

  """
  @spec delete_needs_list(any(), %{id: String.t()}, any()) ::
          {:ok, map()} | {:error, term()}
  def delete_needs_list(_, %{id: id}, _) do
    case Aid.get_needs_list(id) do
      :not_found ->
        {:error, @needs_list_not_found}

      {:ok, needs_list} ->
        Aid.delete_needs_list(needs_list)
    end
  end
end
