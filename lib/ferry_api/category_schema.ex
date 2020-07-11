defmodule FerryApi.Schema.Category do
  use Absinthe.Schema.Notation

  import AbsintheErrorPayload.Payload
  alias Ferry.AidTaxonomy
  alias FerryApi.Middleware

  object :category_queries do
    @desc "Get the # of categories"
    field :count_categories, :integer do
      resolve(&count_categories/3)
    end

    @desc "Get all categories"
    field :categories, list_of(:category) do
      resolve(&list_categories/3)
    end

    @desc "Get a category"
    field :category, :category do
      arg(:id, non_null(:id))
      resolve(&get_category/3)
    end

    @desc "Get a category by name"
    field :category_by_name, :category do
      arg(:name, non_null(:string))
      resolve(&get_category_by_name/3)
    end
  end

  input_object :category_input do
    field :name, :string
  end

  object :category_mutations do
    @desc "Create a category"
    field :create_category, type: :category_payload do
      arg(:category_input, non_null(:category_input))
      middleware(Middleware.RequireUser)
      resolve(&create_category/3)
      middleware(&build_payload/2)
    end

    @desc "Update a category"
    field :update_category, type: :category_payload do
      arg(:id, non_null(:id))
      arg(:category_input, non_null(:category_input))
      middleware(Middleware.RequireUser)
      resolve(&update_category/3)
      middleware(&build_payload/2)
    end

    @desc "Delete a category"
    field :delete_category, type: :category_payload do
      arg(:id, non_null(:id))
      middleware(Middleware.RequireUser)
      resolve(&delete_category/3)
      middleware(&build_payload/2)
    end
  end

  @category_not_found "category not found"

  @doc """
  Graphql resolver that returns the total number of categories
  """
  @spec count_categories(map(), map(), Absinthe.Resolution.t()) :: {:ok, non_neg_integer()}
  def count_categories(_parent, _args, _resolution) do
    {:ok, length(AidTaxonomy.list_categories())}
  end

  @doc """
  Graphql resolver that returns a collection of entities
  """
  @spec list_categories(map(), map(), Absinthe.Resolution.t()) ::
          {:ok, [AidTaxonomy.Category.t()]}
  def list_categories(_parent, _args, _resolution) do
    {:ok, AidTaxonomy.list_categories()}
  end

  @doc """
  Graphql resolver that returns a single category, given its id
  """
  @spec get_category(any, %{id: integer}, any) ::
          {:error, String.t()} | {:ok, Ferry.AidTaxonomy.Category.t()}
  def get_category(_parent, %{id: id}, _resolution) do
    case AidTaxonomy.get_category(id) do
      nil ->
        {:error, @category_not_found}

      category ->
        {:ok, category}
    end
  end

  @doc """
  Graphql resolver that returns a single category, given its name
  """
  @spec get_category_by_name(any, %{name: binary}, any) ::
          {:error, String.t()} | {:ok, Ferry.AidTaxonomy.Category.t()}
  def get_category_by_name(_parent, %{name: name}, _resolution) do
    case AidTaxonomy.get_category_by_name(name) do
      nil ->
        {:error, @category_not_found}

      category ->
        {:ok, category}
    end
  end

  @doc """
  Graphql resolver that creates a category
  """
  @spec create_category(
          any,
          %{category_input: map()},
          any
        ) :: {:error, Ecto.Changeset.t()} | {:ok, Ferry.AidTaxonomy.Category.t()}
  def create_category(_parent, %{category_input: category_attrs}, _resolution) do
    AidTaxonomy.create_category(category_attrs)
  end

  @doc """
  Graphql resolver that updates an existing category
  """
  @spec update_category(any, %{category_input: any, id: integer}, any) ::
          {:error, String.t() | Ecto.Changeset.t()} | {:ok, Ferry.AidTaxonomy.Category.t()}
  def update_category(_parent, %{id: id, category_input: category_attrs}, _resolution) do
    case AidTaxonomy.get_category(id) do
      nil ->
        {:error, @category_not_found}

      category ->
        AidTaxonomy.update_category(category, category_attrs)
    end
  end

  @doc """
  Graphql resolver that deletes an existing category
  """
  @spec delete_category(any, %{id: integer}, any) ::
          {:error, String.t() | Ecto.Changeset.t()} | {:ok, Ferry.AidTaxonomy.Category.t()}
  def delete_category(_parent, %{id: id}, _resolution) do
    case AidTaxonomy.get_category(id) do
      nil -> {:error, @category_not_found}
      category -> AidTaxonomy.delete_category(category)
    end
  end
end
