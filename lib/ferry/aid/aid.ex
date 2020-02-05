defmodule Ferry.Aid do
  @moduledoc """
  The Aid context.
  """

  import Ecto.Query, warn: false
  alias Ferry.Repo
  alias Ecto.Changeset

  alias Ferry.Aid.Item
  alias Ferry.Aid.ItemCategory
  alias Ferry.Aid.Mod

  # Item Category
  # ================================================================================

  # TODO: test that items are ordered by name
  # TODO: test with_mods? == true
  def list_item_categories(with_mods? \\ false) do
    item_category_query(with_mods?)
    |> Repo.all()
  end

  # TODO: test with_mods? == true
  def get_item_category!(id, with_mods? \\ false) do
    item_category_query(with_mods?)
    |> Repo.get!(id)
  end

  # TODO: create_or_get?
  def create_item_category(attrs \\ %{}) do
    %ItemCategory{}
    |> ItemCategory.changeset(attrs)
    |> Repo.insert()
  end

  def update_item_category(%ItemCategory{} = category, attrs \\ %{}) do
    category
    |> ItemCategory.changeset(attrs)
    |> Repo.update()
  end

  # Categories can ONLY be deleted when:
  #
  #   - The Category doesn't reference any Items.
  #   - The Category references Items, but they aren't referenced by Entries.
  #     In this case all the Items will be deleted, but Mods referenced by the
  #     Item will be left as is (even if that's the only Item referencing them).
  #
  # Categories CANNOT be deleted when:
  #
  #   - The Category references Items which are referenced by Entries.
  #     Categories are controlled by site admins, and an admin action should not
  #     affect user data in such a sweeping way.  It'd be too easy to
  #     unintentionally wipe a lot of Entries off of lists, and usage is a good
  #     indication that the Category is needed.
  #
  # This policy is enforced at the database level, by setting appropriate values
  # for the reference's :on_delete option in a migration.
  #
  # TODO: Add ability to archive Categories & Items, so existing Entries are
  #       unaffected but the Category / Items can't be selected for new Entries.
  def delete_item_category(%ItemCategory{} = category) do
    category
    # TODO: ItemCategory.delete_changeset that only checks fkey constraints?
    |> ItemCategory.changeset() # handle db constraint errors as changeset errors
    |> Repo.delete()
  end

  # TODO: test
  def change_item_category(%ItemCategory{} = category) do
    ItemCategory.changeset(category, %{})
  end

  # Helpers
  # ------------------------------------------------------------

  defp item_category_query(false) do
    from category in ItemCategory,
      left_join: item in assoc(category, :items),
      order_by: [category.name, item.name],
      preload: [items: item]
  end

  defp item_category_query(true) do
    from category in ItemCategory,
      left_join: item in assoc(category, :items),
      left_join: mod in assoc(item, :mods),
      order_by: [category.name, item.name, mod.name],
      preload: [items: {item, mods: mod}]
  end

  # Item
  # ================================================================================

  # NOTE: No `list_items()` because we always want them to be organized by
  #       category.  Use `list_item_categories()` instead.

  def get_item!(id) do
    item_query()
    |> Repo.get!(id)
  end

  def create_item(%ItemCategory{} = category, attrs \\ %{}) do
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
    |> Item.changeset() # handle db constraint errors as changeset errors
    |> Repo.delete()
  end

  # TODO: test
  def change_item(%Item{} = item) do
    Item.changeset(item, %{})
  end

  # Helpers
  # ------------------------------------------------------------

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

  # from server data: mods = [%{id: 4}, ...]
  #                   mods = [%Mod{id: 4}, ...]
  # NOTE: Should we check if mods is a list of %Mod{} structs and return that
  #       directly instead of looking them up again?
  defp get_item_mods(%{mods: mods}) do
    mods
    |> Enum.map(&(&1.id))
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
    |> Mod.update_changeset() # handle db constraint errors as changeset errors
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
    |> Enum.map(&(&1.id))
    |> get_mod_items()
  end

  # from client data: items = [%{"id" => "4"}, ...]
  defp get_mod_items(%{"items" => items}) do
    items
    |> Enum.map(&(&1["id"] |> String.to_integer()))
    |> get_mod_items()
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
