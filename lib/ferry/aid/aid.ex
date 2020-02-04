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

  # TODO: order items by name
  def list_item_categories() do
    query =
      from category in ItemCategory,
        left_join: item in assoc(category, :items),
        order_by: category.name,
        preload: [items: item]

    Repo.all(query)
  end

  def get_item_category!(id) do
    query =
      from category in ItemCategory,
        left_join: item in assoc(category, :items),
        order_by: item.name,
        preload: [items: item]

    Repo.get!(query, id)
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

  # Item
  # ================================================================================

  # TODO: is needed? should probably just use list_categories
  # def list_items() do
  # end

  def get_item!(id) do
    query =
      from item in Item,
        join: category in assoc(item, :category),
        left_join: mod in assoc(item, :mods),
        order_by: mod.name,
        preload: [
          category: category,
          mods: mod
        ]

    Repo.get!(query, id)
  end

  def create_item(%ItemCategory{} = category, attrs \\ %{mods: []}) do
    Ecto.build_assoc(category, :items)
    |> Item.changeset(attrs)
    |> Changeset.put_assoc(:mods, attrs.mods)
    |> Repo.insert()
  end

  def update_item(%Item{} = item, attrs \\ %{mods: []}) do
    item
    |> Repo.preload(:mods)
    |> Item.changeset(attrs)
    |> Changeset.put_assoc(:mods, attrs.mods)
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

  # Mod
  # ================================================================================

  # TODO: preload items & categories
  def list_mods() do
    query =
      from mod in Mod,
        order_by: mod.name

    Repo.all(query)
  end

  # TODO: order items by category.name then by item.name
  def get_mod!(id) do
    query =
      from mod in Mod,
        left_join: item in assoc(mod, :items),
        left_join: category in assoc(item, :category),
        preload: [items: {item, category: category}]

    Repo.get!(query, id)
  end

  def create_mod(attrs \\ %{items: []}) do
    %Mod{}
    |> Mod.create_changeset(attrs)
    |> Changeset.put_assoc(:items, attrs.items) # TODO: explicitly lookup items from the db?
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
  def update_mod(%Mod{} = mod, attrs \\ %{items: []}) do
    mod
    |> Repo.preload(:items)
    |> Mod.update_changeset(attrs)
    |> Changeset.put_assoc(:items, attrs.items)
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

end
