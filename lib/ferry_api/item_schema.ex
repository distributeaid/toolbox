defmodule FerryApi.Schema.Item do
  use Absinthe.Schema.Notation

  import AbsintheErrorPayload.Payload
  alias FerryApi.Middleware
  alias Ferry.AidTaxonomy
  alias Ferry.AidTaxonomy.Item

  object :item_queries do
    @desc "Get the # of items"
    field :count_items, :integer do
      resolve(&count_items/3)
    end

    @desc "Get a item"
    field :item, :item do
      arg(:id, non_null(:id))
      resolve(&get_item/3)
    end

    @desc "Get a item by name"
    field :item_by_name, :item do
      arg(:category, non_null(:string))
      arg(:name, non_null(:string))
      resolve(&get_item_by_name/3)
    end
  end

  input_object :item_input do
    field :name, :string
    field :category, :id
  end

  object :item_mutations do
    @desc "Create a item"
    field :create_item, type: :item_payload do
      arg(:item_input, non_null(:item_input))
      middleware(Middleware.RequireUser)
      resolve(&create_item/3)
      middleware(&build_payload/2)
    end

    @desc "Update a item"
    field :update_item, type: :item_payload do
      arg(:id, non_null(:id))
      arg(:item_input, non_null(:item_input))
      middleware(Middleware.RequireUser)
      resolve(&update_item/3)
      middleware(&build_payload/2)
    end

    @desc "Move an item to a new category"
    field :update_item_category, type: :item_payload do
      arg(:id, non_null(:id))
      arg(:category, non_null(:id))
      middleware(Middleware.RequireUser)
      resolve(&update_item_category/3)
      middleware(&build_payload/2)
    end

    @desc "Delete a item"
    field :delete_item, type: :item_payload do
      arg(:id, non_null(:id))
      middleware(Middleware.RequireUser)
      resolve(&delete_item/3)
      middleware(&build_payload/2)
    end
  end

  @item_not_found "item not found"
  @category_not_found "category not found"

  @doc """
  Graphql resolver that returns the total number of items, across
  all categories
  """
  @spec count_items(map(), map(), Absinthe.Resolution.t()) :: {:ok, non_neg_integer()}
  def count_items(_parent, _args, _resolution) do
    {:ok, AidTaxonomy.count_items()}
  end

  @doc """
  Graphql resolver that returns a single item, given its id
  """
  @spec get_item(any(), %{id: String.t()}, any()) ::
          {:error, String.t()} | {:ok, Item.t()}
  def get_item(_parent, %{id: id}, _resolution) do
    case id |> String.to_integer() |> AidTaxonomy.get_item() do
      nil ->
        {:error, @item_not_found}

      item ->
        {:ok, item}
    end
  end

  @doc """
  Graphql resolver that returns a single item, given its name.

  This resolver first needs to lookup the category, since the
  name is not unique across categories.
  """
  @spec get_item_by_name(any, %{category: String.t(), name: String.t()}, any) ::
          {:error, String.t()} | {:ok, Item.t()}
  def get_item_by_name(_parent, %{category: category, name: name}, _resolution) do
    case category |> String.to_integer() |> AidTaxonomy.get_category() do
      nil ->
        {:error, @category_not_found}

      category ->
        case AidTaxonomy.get_item_by_name(category, name) do
          nil ->
            {:error, @item_not_found}

          item ->
            {:ok, item}
        end
    end
  end

  @doc """
  Graphql resolver that creates a item for a given category

  If the category does not exist, then an error is returned.
  """
  @spec create_item(
          any,
          %{item_input: map()},
          any
        ) :: {:error, Ecto.Changeset.t()} | {:ok, Item.t()}
  def create_item(_parent, %{item_input: item_attrs}, _resolution) do
    case AidTaxonomy.get_category(item_attrs.category) do
      nil ->
        {:error, @category_not_found}

      category ->
        AidTaxonomy.create_item(category, item_attrs)
    end
  end

  @doc """
  Graphql resolver that updates an existing item
  """
  @spec update_item(any(), %{item_input: any, id: String.t()}, any()) ::
          {:error, String.t() | Ecto.Changeset.t()} | {:ok, Item.t()}
  def update_item(_parent, %{id: id, item_input: item_attrs}, _resolution) do
    case id |> String.to_integer() |> AidTaxonomy.get_item() do
      nil ->
        {:error, @item_not_found}

      item ->
        AidTaxonomy.update_item(item, item_attrs)
    end
  end

  @doc """
  Graphql resolver that updates an existing item
  """
  @spec update_item_category(any(), %{category: String.t(), id: String.t()}, any()) ::
          {:error, String.t() | Ecto.Changeset.t()} | {:ok, Item.t()}
  def update_item_category(_parent, %{id: id, category: category}, _resolution) do
    case id |> String.to_integer() |> AidTaxonomy.get_item() do
      nil ->
        {:error, @item_not_found}

      item ->
        case category |> String.to_integer() |> AidTaxonomy.get_category() do
          nil ->
            {:error, @category_not_found}

          category ->
            AidTaxonomy.update_item_category(item, category)
        end
    end
  end

  @doc """
  Graphql resolver that deletes an existing item
  """
  @spec delete_item(any, %{id: String.t()}, any) ::
          {:error, String.t() | Ecto.Changeset.t()} | {:ok, Item.t()}
  def delete_item(_parent, %{id: id}, _resolution) do
    case id |> String.to_integer() |> AidTaxonomy.get_item() do
      nil -> {:error, @item_not_found}
      item -> AidTaxonomy.delete_item(item)
    end
  end
end
