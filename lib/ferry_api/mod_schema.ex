defmodule FerryApi.Schema.Mod do
  use Absinthe.Schema.Notation

  import AbsintheErrorPayload.Payload
  alias Ferry.AidTaxonomy
  alias FerryApi.Middleware

  object :mod_queries do
    @desc "Get the # of mods"
    field :count_mods, :integer do
      resolve(&count_mods/3)
    end

    @desc "Get all mods"
    field :mods, list_of(:mod) do
      resolve(&list_mods/3)
    end

    @desc "Get a mod"
    field :mod, :mod do
      arg(:id, non_null(:id))
      resolve(&get_mod/3)
    end

    @desc "Get a mod by name"
    field :mod_by_name, :mod do
      arg(:name, non_null(:string))
      resolve(&get_mod_by_name/3)
    end
  end

  # TODO: what is this?
  input_object :mod_input do
    field :name, :string
    field :description, :string
    field :type, :string
  end

  object :mod_mutations do
    @desc "Create a mod"
    field :create_mod, type: :mod_payload do
      arg(:mod_input, non_null(:mod_input))
      middleware(Middleware.RequireUser)
      resolve(&create_mod/3)
      middleware(&build_payload/2)
    end

    @desc "Update a mod"
    field :update_mod, type: :mod_payload do
      arg(:id, non_null(:id))
      arg(:mod_input, non_null(:mod_input))
      middleware(Middleware.RequireUser)
      resolve(&update_mod/3)
      middleware(&build_payload/2)
    end

    @desc "Delete a mod"
    field :delete_mod, type: :mod_payload do
      arg(:id, non_null(:id))
      middleware(Middleware.RequireUser)
      resolve(&delete_mod/3)
      middleware(&build_payload/2)
    end

    @desc "Add a mod to an existing item"
    field :add_mod_to_item, type: :mod_payload do
      arg(:mod, non_null(:id))
      arg(:item, non_null(:id))
      middleware(Middleware.RequireUser)
      resolve(&add_mod_to_item/3)
      middleware(&build_payload/2)
    end
  end

  @mod_not_found "mod not found"
  @item_not_found "item not found"

  @doc """
  Graphql resolver that returns the total number of mods
  """
  @spec count_mods(map(), map(), Absinthe.Resolution.t()) :: {:ok, non_neg_integer()}
  def count_mods(_parent, _args, _resolution) do
    {:ok, length(AidTaxonomy.list_mods())}
  end

  @doc """
  Graphql resolver that returns a collection of entities
  """
  @spec list_mods(map(), map(), Absinthe.Resolution.t()) ::
          {:ok, [AidTaxonomy.Mod.t()]}
  def list_mods(_parent, _args, _resolution) do
    {:ok, AidTaxonomy.list_mods()}
  end

  @doc """
  Graphql resolver that returns a single mod, given its id
  """
  @spec get_mod(any, %{id: integer}, any) ::
          {:error, String.t()} | {:ok, Ferry.AidTaxonomy.Mod.t()}
  def get_mod(_parent, %{id: id}, _resolution) do
    case AidTaxonomy.get_mod(id) do
      nil ->
        {:error, @mod_not_found}

      mod ->
        {:ok, mod}
    end
  end

  @doc """
  Graphql resolver that returns a single mod, given its name
  """
  @spec get_mod_by_name(any, %{name: binary}, any) ::
          {:error, String.t()} | {:ok, Ferry.AidTaxonomy.Mod.t()}
  def get_mod_by_name(_parent, %{name: name}, _resolution) do
    case AidTaxonomy.get_mod_by_name(name) do
      nil ->
        {:error, @mod_not_found}

      mod ->
        {:ok, mod}
    end
  end

  @doc """
  Graphql resolver that creates a mod
  """
  @spec create_mod(
          any,
          %{mod_input: map()},
          any
        ) :: {:error, Ecto.Changeset.t()} | {:ok, Ferry.AidTaxonomy.Mod.t()}
  def create_mod(_parent, %{mod_input: mod_attrs}, _resolution) do
    AidTaxonomy.create_mod(mod_attrs)
  end

  @doc """
  Graphql resolver that updates an existing mod
  """
  @spec update_mod(any, %{mod_input: any, id: integer}, any) ::
          {:error, String.t() | Ecto.Changeset.t()} | {:ok, Ferry.AidTaxonomy.Mod.t()}
  def update_mod(_parent, %{id: id, mod_input: mod_attrs}, _resolution) do
    case AidTaxonomy.get_mod(id) do
      nil ->
        {:error, @mod_not_found}

      mod ->
        AidTaxonomy.update_mod(mod, mod_attrs)
    end
  end

  @doc """
  Graphql resolver that deletes an existing mod
  """
  @spec delete_mod(any, %{id: integer}, any) ::
          {:error, String.t() | Ecto.Changeset.t()} | {:ok, Ferry.AidTaxonomy.Mod.t()}
  def delete_mod(_parent, %{id: id}, _resolution) do
    case AidTaxonomy.get_mod(id) do
      nil -> {:error, @mod_not_found}
      mod -> AidTaxonomy.delete_mod(mod)
    end
  end

  @doc """
  GraphQL resolver that adds an existing mod to an item
  """
  @spec add_mod_to_item(any, %{mod: integer(), item: integer()}, any) ::
          {:error, String.t() | Ecto.Changeset.t()} | {:ok, Ferry.AidTaxonomy.Mod.t()}
  def add_mod_to_item(_parent, %{mod: mod, item: item}, _resolution) do
    case AidTaxonomy.get_mod(mod) do
      nil ->
        {:error, @mod_not_found}

      mod ->
        case AidTaxonomy.get_item(item) do
          nil ->
            {:error, @item_not_found}

          item ->
            AidTaxonomy.add_mod_to_item(mod, item)
        end
    end
  end
end
