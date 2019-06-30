defmodule Ferry.Inventory do
  @moduledoc """
  The Inventory context.
  """

  import Ecto.Query, warn: false
  alias Ferry.Repo
  alias Ecto.Multi
  alias Ecto.Changeset

  alias Ferry.Profiles.Group
  alias Ferry.Inventory.InventoryList
  alias Ferry.Inventory.InventoryListControls, as: Controls
  alias Ferry.Inventory.{
    Category,
    Item,
    Mod,
    Stock
  }


  # Inventory List
  # ================================================================================

  @doc """
  Gets an inventory list, which sets the filter fields and gets the matching
  stocks from the database.

  ## Examples

      iex> get_inventory_list(:type, [group_filter: [id1, id2, ...]])
      %{
        control_data: %{
          group_filter: [{"Group Name", id}, ...]
        },

        controls: %Ecto.Changeset{
          group_filter: [id1, id2, ...]
        },

        results: [%Stock{}, ...]
      }

      iex> get_inventory_list(:type, [group_filter: ["not an id"]])
      %{
        control_data: %{
          group_filter: [{"Group Name", id}, ...]
        },

        controls: %Ecto.Changeset{},

        results: []
      }
  """
  def get_inventory_list(type, controls \\ %{}) when type in [:available, :needs] do
    control_data = %{
      group_filter: get_group_filter_labels()
    }
    controls = %Controls{} |> Controls.changeset(controls)

    results = case controls.valid? do
      true ->
        controls
        |> Changeset.apply_changes()
        |> list_inventory(type)
      false -> []
    end

    %{
      control_data: control_data,
      controls: controls,
      results: results
    }
  end

  # TODO: based on `set_control_labels` in /lib/ferry/locations.ex
  #       need to refactor
  defp get_group_filter_labels() do
    # TODO: move to Profiles context for better encapsulation?
    Repo.all(from g in Group,
      select: {g.name, g.id},
      order_by: g.name
    )
  end

  defp list_inventory(controls, type) do
    full_stock_query()
    |> inventory_list_type_filter(type)
    |> apply_group_filter(controls)
    |> order_stock_list()
    |> Repo.all()
  end

  defp inventory_list_type_filter(query, :available) do
    from s in query,
    where: s.have > s.need
  end

  defp inventory_list_type_filter(query, :needs) do
    from s in query,
    where: s.have < s.need
  end

  defp apply_group_filter(query, %Controls{group_filter: group_filter}) do
    case group_filter do
      # empty- don't filter
      nil -> query
      [] -> query

      # not empty- filter for selected groups
      _ ->
        from [s, p, g] in query,
        where: g.id in ^group_filter
    end
  end

  defp order_stock_list(query) do
    from [s] in query,
      order_by: s.id
  end


  # Stock
  # ================================================================================
  # NOTE: Stocks are the primary way of interacting with the inventory
  #       management system. They expose public functions which govern creating,
  #       updating, and deleting other Inventory schemas.  Thus these functions
  #       should be defined privately at the end of this file, and tested
  #       through the Stock functions.
  #
  #       The general exception to this rule is getter functions which may be
  #       necessary to facilitate UI lists, forms, and search functionality.

  defp full_stock_query() do
    from s in Stock,
      join: proj in assoc(s, :project),
      join: g in assoc(proj, :group),

      join: i in assoc(s, :item),
      join: c in assoc(i, :category),

      join: m in assoc(s, :mod),
      left_join: p in assoc(s, :packaging),

      preload: [
        project: {proj, group: g},
        item: {i, category: c},
        mod: m,
        packaging: p
      ]
  end

  @doc """
  Returns the list of stocks.

  ## Examples

      iex> list_stocks()
      [%Stock{}, ...]

  """
  def list_stocks do
    Repo.all(full_stock_query())
  end

  @doc """
  Gets a single stock.

  Raises `Ecto.NoResultsError` if the Stock does not exist.

  ## Examples

      iex> get_stock!(123)
      %Stock{}

      iex> get_stock!(456)
      ** (Ecto.NoResultsError)

  """
  def get_stock!(id) do
    Repo.get!(full_stock_query(), id)
  end

  @doc """
  Creates a stock.

  ## Examples

      iex> create_stock(%{field: value})
      {:ok, %Stock{}}

      iex> create_stock(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  # TODO:  - virtual item matching direct input,
  #        - validate that all at once by combining all the other validations,
  #        - do that by running a special changeset on each schema which tests
  #          each field, but not dependencies which may not exist yet
  #        - if all the fields pass, all the dependencies should be met after
  #          retrieving them / creating them; throw a server error if they are
  #          not- DB errors will still be thrown, or they could be revalidated
  #          with dependencies a 2nd time before creation
  def create_stock(attrs \\ %{}) do
    {_, category} = get_or_create_category(attrs["item"]["category"])
    {_, item} = get_or_create_item(category, attrs["item"])
    {:ok, mod} = get_mod(attrs["mod"])

    attrs = Map.merge(attrs, %{
      "item" => item,
      "mod" => mod,
    })

    {status, result} = %Stock{}
    |> Stock.changeset(attrs)
    |> Repo.insert()

    case status do
      :ok -> result
        |> Stock.image_changeset(attrs)
        |> Repo.update()
      :error -> {status, result}
    end
  end

  @doc """
  Updates a stock.

  ## Examples

      iex> update_stock(stock, %{field: new_value})
      {:ok, %Stock{}}

      iex> update_stock(stock, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_stock(%Stock{} = stock, attrs) do
    {_, category} = get_or_create_category(attrs["item"]["category"])
    {_, item} = get_or_create_item(category, attrs["item"])
    {:ok, mod} = get_mod(attrs["mod"])

    attrs = Map.merge(attrs, %{
      "item" => item,
      "mod" => mod,
    })

    stock
    |> Stock.changeset(attrs)
    |> Stock.image_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Stock.

  ## Examples

      iex> delete_stock(stock)
      {:ok, %Stock{}}

      iex> delete_stock(stock)
      {:error, %Ecto.Changeset{}}

  """
  def delete_stock(%Stock{} = stock) do
    steps = Multi.new |> Multi.delete(:stock, stock)

    steps = if stock.packaging do
      steps |> Multi.delete(:packaging, stock.packaging)
    else
      steps
    end

    Repo.transaction(steps)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking stock changes.

  ## Examples

      iex> change_stock(stock)
      %Ecto.Changeset{source: %Stock{}}

  """
  def change_stock(%Stock{} = stock) do
    Stock.validate(stock)
  end


  # Category
  # ================================================================================

  def list_top_categories(n \\ 10) do
    Repo.all(
      from c in Category,
      left_join: i in assoc(c, :items),
      left_join: s in assoc(i, :stocks),
      group_by: c.id,
      order_by: [desc: count(c.id), asc: c.id],
      limit: ^n,
      select_merge: %{stock_reference_count: count(c.id)}
    )
  end

  defp get_or_create_category(attrs \\ %{})

  defp get_or_create_category(%{"name" => name} = attrs) do
    case Repo.get_by(Category, name: name) do
      %Category{} = category ->
        {:ok, category}
      nil ->
        create_category(attrs)
    end
  end

  defp get_or_create_category(attrs) do
    create_category(attrs)
  end

  defp create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end


  # Item
  # ================================================================================

  # TODO: Gives top 100 items, which may / may not correspond to the top 10
  #       categories in `list_top_categories`.  Should combine these two and
  #       present a single category & item select input on the stock creation
  #       form, with categories forming the opt-group and items organized as
  #       selections within them.
  def list_top_items(n \\ 100) do
    Repo.all(
      from i in Item,
#      join: c in assoc(i, :category),
      left_join: s in assoc(i, :stocks),
      group_by: i.id,
      order_by: [desc: count(i.id), asc: i.id],
      limit: ^n,
      select_merge: %{stock_reference_count: count(i.id)}
    )
  end

  defp get_or_create_item(category_or_changeset, attrs \\ %{})

  defp get_or_create_item(%Category{} = category, attrs) do
    item = Repo.one(from i in Item,
      where: i.name == ^attrs["name"]
         and i.category_id == ^category.id,
      join: c in assoc(i, :category),
      preload: [category: c]
    )

    case item do
      %Item{} -> {:ok, item}
      _ ->
        attrs = attrs |> Map.put("category", category)
        %Item{}
        |> Item.changeset(attrs)
        |> Repo.insert()
    end
  end

  defp get_or_create_item(%Changeset{} = category_changeset, attrs) do
    attrs = attrs |> Map.put("category", category_changeset)
    changeset = %Item{} |> Item.changeset(attrs)
    {:error, changeset}
  end


  # Mod
  # ================================================================================

  defp get_mod(attrs \\ %{}) do
    query = from m in Mod

    filter_keys = [:gender, :age, :size, :season]
    query = Enum.reduce(filter_keys, query, fn key, query ->
      value = Map.get(attrs, Atom.to_string(key))
      if value != "" && value != nil do
        from m in query, where: field(m, ^key) == ^value
      else
        from m in query, where: is_nil field(m, ^key)
      end
    end)

    mod = Repo.one!(query)

    {:ok, mod} # standardize return with related Category & Item functions
  end


  # Packaging
  # ================================================================================
  # NOTE: Packaging data is managed alongside the Stock data for now, using
  #       `cast_assoc`.  Thus no need for a create / update / delete function.
end
