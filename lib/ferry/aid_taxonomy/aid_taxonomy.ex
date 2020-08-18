defmodule Ferry.AidTaxonomy do
  @moduledoc """
  The AidTaxonomy context.

  Prevent circular dependencies with the Aid context!  The Aid context is
  dependent on an AidTaxonomy, but the reverse is not true.  For example,
  rather than putting a `get_entries_for_item` function here, put a
  `get_entries_by_item` function in the Aid context.
  """

  import Ecto.Query, warn: false
  alias Ferry.Repo
  alias Ecto.Changeset

  alias Ferry.AidTaxonomy.Category
  alias Ferry.AidTaxonomy.Item
  alias Ferry.AidTaxonomy.Mod

  @doc """
  Returns all categories

  Categories are sorted by name. By default, categories are returned without mods.
  Passing `true` to this function will traverse items on each category
  and return their mods.

  TODO: test with_mods? == true
  """
  @spec list_categories(boolean) :: [Category.t()]
  def list_categories(with_mods? \\ false) do
    category_query(with_mods?)
    |> Repo.all()
  end

  @doc """
  Given its id, return the associated category.

  If no category matches the given id, then an error will be raised

  TODO: test with_mods? == true
  """
  @spec get_category!(integer(), boolean) :: Category.t()
  def get_category!(id, with_mods? \\ false) do
    category_query(with_mods?)
    |> Repo.get!(id)
  end

  @doc """
  Given its id, return the associated category.

  If no category matches, then this function returns nil
  TODO: test with_mods? == true
  """
  @spec get_category(integer(), boolean) :: Category.t() | nil
  def get_category(id, with_mods? \\ false) do
    category_query(with_mods?)
    |> Repo.get(id)
  end

  @doc """
  Given its name, return the associated category

  If no category was found, then this function returns nil
  TODO: test with_mods? == true
  """
  @spec get_category_by_name(String.t(), boolean) :: Category.t() | nil
  def get_category_by_name(name, with_mods? \\ false) do
    category_query(with_mods?)
    |> Repo.get_by(name: name)
  end

  @doc """
  Create a new category for the given attributes.

  The name for the category must be unique.
  # TODO: create_or_get?
  """
  @spec create_category(map()) :: {:ok, Category.t()} | {:error, Ecto.Changeset.t()}
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Given a category, update it with the given new attributes.

  If the category does not exist, then an error will be raised
  """
  @spec update_category(
          Ferry.AidTaxonomy.Category.t(),
          map()
        ) :: {:ok, Category.t()} | {:error, Ecto.Changeset.t()}
  def update_category(%Category{} = category, attrs \\ %{}) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Given a category, delete it.

  Categories can ONLY be deleted when:

     - The Category doesn't reference any Items.
     - The Category references Items, but they aren't referenced by Entries.
       In this case all the Items will be deleted, but Mods referenced by the
       Item will be left as is (even if that's the only Item referencing them).

   Categories CANNOT be deleted when:

     - The Category references Items which are referenced by Entries.
       Categories are controlled by site admins, and an admin action should not
       affect user data in such a sweeping way.  It'd be too easy to
       unintentionally wipe a lot of Entries off of lists, and usage is a good
       indication that the Category is needed.

   This policy is enforced at the database level, by setting appropriate values
   for the reference's :on_delete option in a migration.

   TODO: Add ability to archive Categories & Items, so existing Entries are
         unaffected but the Category / Items can't be selected for new Entries.
  """
  @spec delete_category(Category.t()) :: {:ok, Category.t()} | {:error, Ecto.Changeset.t()}
  def delete_category(%Category{} = category) do
    category
    # TODO: Category.delete_changeset that only checks fkey constraints?
    # handle db constraint errors as changeset errors
    |> Category.changeset()
    |> Repo.delete()
  end

  #
  # Helpers
  # ------------------------------------------------------------

  defp category_query(false) do
    from category in Category,
      left_join: item in assoc(category, :items),
      order_by: [category.name, item.name],
      preload: [items: item]
  end

  defp category_query(true) do
    from category in Category,
      left_join: item in assoc(category, :items),
      left_join: mod in assoc(item, :mods),
      order_by: [category.name, item.name, mod.name],
      preload: [items: {item, mods: mod}]
  end

  # Item
  # ================================================================================

  # NOTE: No `list_items()` because we always want them to be organized by
  #       category.  Use `list_categories()` instead.

  @doc """
  Count the total number of items in the database
  """
  @spec count_items() :: Integer.t()
  def count_items() do
    Item
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Given its id, return the associated item.

  If no item matches, then this function returns nil
  TODO: test with_mods? == true
  """
  @spec get_item(integer(), boolean) :: Item.t() | nil
  def get_item(id, _with_mods? \\ false) do
    item_query()
    |> Repo.get(id)
  end

  @doc """
  Given its id, return the associated item.

  If no item matches, then this function returns an error
  TODO: test with_mods? == true
  """
  @spec get_item!(integer(), boolean) :: Item.t()
  def get_item!(id, _with_mods \\ false) do
    item_query()
    |> Repo.get!(id)
  end

  @doc """
  Given its category and name, return the associated item

  If no item was found, then this function returns nil
  TODO: test with_mods? == true
  """
  @spec get_item_by_name(Category.t(), String.t(), boolean) :: Item.t() | nil
  def get_item_by_name(category, name, _with_mods? \\ false) do
    item_query()
    |> Repo.get_by(category_id: category.id, name: name)
  end

  defp item_query() do
    from item in Item,
      join: category in assoc(item, :category),
      left_join: mod in assoc(item, :mods),
      order_by: [category.name, item.name, mod.name],
      preload: [
        category: category,
        mods: mod
      ]
  end

  def create_item(%Category{} = category, attrs \\ %{}) do
    mods = get_item_mods(attrs)

    Ecto.build_assoc(category, :items)
    |> Item.changeset(attrs)
    |> Changeset.put_assoc(:mods, mods)
    |> Repo.insert()
  end

  # NOTE: Can't change the Category (Item.changeset doesn't cast `:category_id`).
  # TODO: Do we want this?  Here or explicitly in a "move_category" function?
  def update_item(%Item{} = item, attrs \\ %{}) do
    mods = get_item_mods(attrs)

    item
    |> Repo.preload(:mods)
    |> Item.changeset(attrs)
    |> Changeset.put_assoc(:mods, mods)
    |> Repo.update()
  end

  # Mods referenced by the Item will be left as is (even if that's the only Item
  # referencing them).
  #
  # Items can ONLY be deleted when:
  #
  #   - The Item doesn't reference any Entries.
  #
  # Items CANNOT be deleted when:
  #
  #   - Items are referenced by Entries.
  #     Items are controlled by site admins, and an admin action should not
  #     affect user data in such a sweeping way.  It'd be too easy to
  #     unintentionally wipe a lot of Entries off of lists, and usage is a good
  #     indication that the Item is needed.
  #
  # This policy is enforced at the database level, by setting appropriate values
  # for the reference's :on_delete option in a migration.
  #
  # TODO: Add ability to archive Categories & Items, so existing Entries are
  #       unaffected but the Category / Items can't be selected for new Entries.
  def delete_item(%Item{} = item) do
    item
    # TODO: Item.delete_changeset that only checks fkey constraints?
    # handle db constraint errors as changeset errors
    |> Item.changeset()
    |> Repo.delete()
  end

  # TODO: test
  def change_item(%Item{} = item) do
    Item.changeset(item, %{})
  end

  # Helpers
  # ------------------------------------------------------------

  # defp item_query() do
  #   from item in Item,
  #     join: category in assoc(item, :category),
  #     left_join: mod in assoc(item, :mods),
  #     order_by: [category.name, item.name, mod.name],
  #     preload: [
  #       category: category,
  #       mods: mod
  #     ]
  # end

  # from server data: mods = [%{id: 4}, ...]
  #                   mods = [%Mod{id: 4}, ...]
  # NOTE: Should we check if mods is a list of %Mod{} structs and return that
  #       directly instead of looking them up again?
  defp get_item_mods(%{mods: mods}) do
    mods
    |> Enum.map(& &1.id)
    |> get_item_mods()
  end

  # from client data: mods = [%{"id" => "4"}, ...]
  defp get_item_mods(%{"mods" => mods}) do
    mods
    |> Enum.map(&(&1["id"] |> String.to_integer()))
    |> get_item_mods()
  end

  # no mods passed in
  defp get_item_mods(attrs) when is_map(attrs) do
    []
  end

  # mod_ids = [4, ...]
  defp get_item_mods(mod_ids) when is_list(mod_ids) do
    query =
      from mod in Mod,
        where: mod.id in ^mod_ids

    Repo.all(query)
  end

  # Mod
  # ================================================================================

  def list_mods() do
    mod_query()
    |> Repo.all()
  end

  def get_mod!(id) do
    mod_query()
    |> Repo.get!(id)
  end

  def create_mod(attrs \\ %{}) do
    items = get_mod_items(attrs)

    %Mod{}
    |> Mod.create_changeset(attrs)
    |> Changeset.put_assoc(:items, items)
    |> Repo.insert()
  end

  # NOTE: Only non-destructive updates are allowed.  Similar reasoning to the
  #       delete_mod restrictions.
  #
  #   - Can only change mod.type from "select" to "multi-select".
  #   - Can only extend the list of values, not remove existing ones.
  #
  # TODO:
  #
  #   - allow changing anything if there are no ModValues
  #   - allow changing the type from "multi-select" to "select" if all
  #     associated ModValues only have 1 value selected
  #   - allow renaming / merging values (probably in another function)
  #   - allow removing values that aren't used in any ModValue
  def update_mod(%Mod{} = mod, attrs \\ %{}) do
    items = get_mod_items(attrs)

    mod
    |> Repo.preload(:items)
    |> Mod.update_changeset(attrs)
    |> Changeset.put_assoc(:items, items)
    |> Repo.update()
  end

  # Items referenced by the Mod will be left as is.
  #
  # Mods can ONLY be deleted when:
  #
  #   - The Mod isn't referenced by any ModValues.
  #
  # Mods CANNOT be deleted when:
  #
  #   - ModValues reference the Mod.
  #     Mods are controlled by site admins, and an admin action should not
  #     affect user data in such a sweeping way.  It'd be too easy to
  #     unintentionally wipe a lot of ModValues off of Entries, and usage is a
  #     good indication that the Item is needed.
  #
  # This policy is enforced at the database level, by setting appropriate values
  # for the reference's :on_delete option in a migration.
  #
  # TODO: Add ability to archive Mods, so existing ModValues are unaffected but
  #       new ModValues referencing the Mod can't be created.
  def delete_mod(%Mod{} = mod) do
    mod
    # TODO: Mod.delete_changeset that only checks fkey constraints?
    # handle db constraint errors as changeset errors
    |> Mod.update_changeset()
    |> Repo.delete()
  end

  # TODO: test
  def change_mod(%Mod{} = mod) do
    Mod.update_changeset(mod, %{})
  end

  # Helpers
  # ------------------------------------------------------------
  defp mod_query() do
    from mod in Mod,
      left_join: item in assoc(mod, :items),
      left_join: category in assoc(item, :category),
      order_by: [mod.name, category.name, item.name],
      preload: [items: {item, category: category}]
  end

  # from server data: items = [%{id: 4}, ...]
  #                   items = [%Item{id: 4}, ...]
  # NOTE: Should we check if items is a list of %Item{} structs and return that
  #       directly instead of looking them up again?
  defp get_mod_items(%{items: items}) do
    items
    |> Enum.map(& &1.id)
    |> get_mod_items()
  end

  # from client data: items = [%{"id" => "4"}, ...]
  defp get_mod_items(%{"items" => items}) do
    items
    |> Enum.map(&(&1["id"] |> String.to_integer()))
    |> get_mod_items()
  end

  # no items passed in
  defp get_mod_items(attrs) when is_map(attrs) do
    []
  end

  # item_ids = [4, ...]
  defp get_mod_items(item_ids) when is_list(item_ids) do
    query =
      from item in Item,
        where: item.id in ^item_ids,
        left_join: category in assoc(item, :category),
        preload: [category: category]

    Repo.all(query)
  end
end
