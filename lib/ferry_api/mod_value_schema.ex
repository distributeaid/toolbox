defmodule FerryApi.Schema.ModValue do
  use Absinthe.Schema.Notation

  import AbsintheErrorPayload.Payload
  alias Ferry.AidTaxonomy
  alias FerryApi.Middleware

  object :mod_value_queries do
    @desc "Get the total number of mod values in the system"
    field :count_mod_values, :integer do
      resolve(&count_mod_values/3)
    end

    @desc "Get all mod values"
    field :mod_values, list_of(:mod_value) do
      resolve(&list_mod_values/3)
    end

    @desc "Get a single mod value"
    field :mod_value, :mod_value do
      arg(:id, non_null(:id))
      resolve(&get_mod_value/3)
    end
  end

  input_object :mod_value_input do
    field :mod, non_null(:id)
    field :value, non_null(:string)
  end

  object :mod_value_mutations do
    @desc "Create a mod value"
    field :create_mod_value, type: :mod_value_payload do
      arg(:mod_value_input, non_null(:mod_value_input))
      middleware(Middleware.RequireUser)
      resolve(&create_mod_value/3)
      middleware(&build_payload/2)
    end

    @desc "Update a mod value"
    field :update_mod_value, type: :mod_value_payload do
      arg(:id, non_null(:id))
      arg(:mod_value_input, non_null(:mod_input))
      middleware(Middleware.RequireUser)
      resolve(&update_mod_value/3)
      middleware(&build_payload/2)
    end

    @desc "Delete a mod value"
    field :delete_mod_value, type: :mod_value_payload do
      arg(:id, non_null(:id))
      middleware(Middleware.RequireUser)
      resolve(&delete_mod_value/3)
      middleware(&build_payload/2)
    end
  end

  @mod_value_not_found "mod value not found"
  @mod_not_found "mod not found"

  @doc """
  Graphql resolver that returns the total number of mod values
  """
  @spec count_mod_values(map(), map(), Absinthe.Resolution.t()) :: {:ok, non_neg_integer()}
  def count_mod_values(_parent, _args, _resolution) do
    {:ok, AidTaxonomy.count_mod_values()}
  end

  @doc """
  Graphql resolver that returns a collection of mod values
  """
  @spec list_mod_values(map(), map(), Absinthe.Resolution.t()) ::
          {:ok, [AidTaxonomy.ModValue.t()]}
  def list_mod_values(_parent, _args, _resolution) do
    {:ok, AidTaxonomy.list_mod_values()}
  end

  @doc """
  Graphql resolver that returns a single mod value, given its id
  """
  @spec get_mod_value(any, %{id: integer}, any) ::
          {:error, String.t()} | {:ok, Ferry.AidTaxonomy.ModValue.t()}
  def get_mod_value(_parent, %{id: id}, _resolution) do
    case AidTaxonomy.get_mod_value(id) do
      nil ->
        {:error, @mod_value_not_found}

      mod_value ->
        {:ok, mod_value}
    end
  end

  @doc """
  Graphql resolver that creates a mod value
  """
  @spec create_mod_value(
          any,
          %{mod_input: map()},
          any
        ) :: {:error, Ecto.Changeset.t()} | {:ok, Ferry.AidTaxonomy.ModValue.t()}
  def create_mod_value(_parent, %{mod_value_input: mod_value_attrs}, _resolution) do
    AidTaxonomy.create_mod_value(mod_value_attrs)
  end

  @doc """
  Graphql resolver that updates an existing mod
  """
  @spec update_mod_value(any, %{mod_value_input: any, id: integer}, any) ::
          {:error, String.t() | Ecto.Changeset.t()} | {:ok, Ferry.AidTaxonomy.ModValue.t()}
  def update_mod_value(_parent, %{id: id, mod_value_input: mod_value_attrs}, _resolution) do
    case AidTaxonomy.get_mod_value(id) do
      nil ->
        {:error, @mod_value_not_found}

      mod_value ->
        AidTaxonomy.update_mod_value(mod_value, mod_value_attrs)
    end
  end

  @doc """
  Graphql resolver that deletes an existing mod value
  """
  @spec delete_mod_value(any, %{id: integer}, any) ::
          {:error, String.t() | Ecto.Changeset.t()} | {:ok, Ferry.AidTaxonomy.ModValue.t()}
  def delete_mod_value(_parent, %{id: id}, _resolution) do
    case AidTaxonomy.get_mod_value(id) do
      nil -> {:error, @mod_value_not_found}
      mod_value -> AidTaxonomy.delete_mod_value(mod_value)
    end
  end
end
