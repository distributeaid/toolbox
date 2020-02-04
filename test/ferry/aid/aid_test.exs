defmodule Ferry.AidTest do
  use Ferry.DataCase

  alias Ferry.Aid
  alias Ferry.Aid.Item
  alias Ferry.Aid.ItemCategory
  alias Ferry.Aid.Mod

  # Item Category
  # ================================================================================
  
  describe "item categories" do
    test "list_item_categories/0 returns all categories" do
      # none
      assert Aid.list_item_categories() == []

      # 1
      category1 = insert(:item_category)
      assert Aid.list_item_categories() == [category1]

      # many
      category2 = insert(:item_category)
      assert Aid.list_item_categories() == [category1, category2]

      # ordered by name
      last_category = insert(:item_category, %{name: "Z"})
      first_category = insert(:item_category, %{name: "A"})
      assert Aid.list_item_categories() == [
        first_category,
        category1,
        category2,
        last_category
      ]
    end

    test "get_item_category!/1 returns the requested category" do
      category = insert(:item_category)
      assert Aid.get_item_category!(category.id) == category

      # with items ordered by name
      #
      # NOTE: The `with_item` adds them to the category.items field in order.
      #       This allows us to simply compare the category without having to do
      #       additional checks to validate the category.items order.
      #
      #       We do, however, have to unload some associations the factory sets
      #       by default.
      category =
        category
        |> with_item(%{name: "Z"})
        |> with_item(%{name: "A"})
        |> with_item(%{name: "M"})

      items =
        category.items
        |> without_assoc(:category)
        |> without_assoc(:entries, :many)
        |> without_assoc(:mods, :many)

      category = %{category | items: items}

      assert Aid.get_item_category!(category.id) == category
    end

    test "get_item_category!/1 with a non-existent id throws an error" do
      assert_raise Ecto.NoResultsError, ~r/^expected at least one result but got none in query/, fn ->
        Aid.get_item_category!(1312)
      end
    end

    test "create_item_category/1 with valid data creates a category" do
      attrs = params_for(:item_category)
      assert {:ok, %ItemCategory{} = category} = Aid.create_item_category(attrs)
      assert category.name == attrs.name
    end

    # TODO: ensure each changeset has the right errors
    test "create_item_category/1 with invalid data returns an error changeset" do
      # too short
      attrs = params_for(:invalid_short_item_category)
      assert {:error, %Ecto.Changeset{} = _changeset} = Aid.create_item_category(attrs)

      # too long
      attrs = params_for(:invalid_long_item_category)
      assert {:error, %Ecto.Changeset{} = _changeset} = Aid.create_item_category(attrs)
    end

    test "update_item_category/2 with valid data updates a category" do
      old_category = insert(:item_category) |> with_item() |> with_item()
      attrs = params_for(:item_category)

      assert {:ok, %ItemCategory{} = category} = Aid.update_item_category(old_category, attrs)

      assert category.name != old_category.name
      assert category.name == attrs.name

      # item list shouldn't change
      assert category.items == old_category.items
    end

    # TODO: ensure each changeset has the right errors
    test "update_item_category/2 with invalid data returns error changeset" do
      category = insert(:item_category)

      # too short
      attrs = params_for(:invalid_short_item_category)
      assert {:error, %Ecto.Changeset{}} = Aid.update_item_category(category, attrs)
      assert category == Aid.get_item_category!(category.id)

      # too long
      attrs = params_for(:invalid_long_item_category)
      assert {:error, %Ecto.Changeset{}} = Aid.update_item_category(category, attrs)
      assert category == Aid.get_item_category!(category.id)
    end

    test "delete_item_category/1 deletes a category that isn't referenced by any list entries" do
      # not referenced by items
      category = insert(:item_category)
      assert {:ok, %ItemCategory{}} = Aid.delete_item_category(category)
      assert_raise Ecto.NoResultsError, fn -> Aid.get_item_category!(category.id) end

      # referenced by items that aren't referenced by list entries
      category = insert(:item_category) |> with_item() |> with_item()
      assert {:ok, %ItemCategory{}} = Aid.delete_item_category(category)
      assert_raise Ecto.NoResultsError, fn -> Aid.get_item_category!(category.id) end

      # the items should be deleted as well
      assert_raise Ecto.NoResultsError, fn -> Aid.get_item!(Enum.at(category.items, 0).id) end
      assert_raise Ecto.NoResultsError, fn -> Aid.get_item!(Enum.at(category.items, 1).id) end
    end

    test "delete_item_category/1 doesn't delete categories that are referenced by list entries" do
      category = insert(:item_category)
      item = insert(:aid_item, %{category: category})
      _entry = insert(:list_entry, %{item: item})

      assert {:error, %Ecto.Changeset{}} = Aid.delete_item_category(category)
      assert category.name == Aid.get_item_category!(category.id).name
      assert item.name == Aid.get_item!(item.id).name
      # TODO: getting an entry is still undefined
      # assert entry = Aid.get_entry!(entry.id)
    end
  end

  # Item
  # ================================================================================
  describe "items" do
    test "get_item!/1 returns the requested item" do
      # no mods
      item = insert(:aid_item)
      retrieved_item = Aid.get_item!(item.id)
      assert retrieved_item ==
        item
        |> without_assoc([:category, :items], :many)
        |> without_assoc(:entries, :many)
      assert %ItemCategory{} = retrieved_item.category
      assert retrieved_item.mods == []

      # with mods preloaded in order
      mod1 = insert(:aid_mod, %{name: "Z"}) |> without_assoc(:items, :many)
      mod2 = insert(:aid_mod, %{name: "A"}) |> without_assoc(:items, :many)
      mod3 = insert(:aid_mod, %{name: "M"}) |> without_assoc(:items, :many)
      item = insert(:aid_item, %{mods: [mod1, mod2, mod3]})
      retrieved_item = Aid.get_item!(item.id)
      assert retrieved_item.mods == [mod2, mod3, mod1]
    end

    test "get_item!/1 with a non-existent id throws an error" do
      assert_raise Ecto.NoResultsError, ~r/^expected at least one result but got none in query/, fn ->
        Aid.get_item!(1312)
      end
    end

    test "create_item/2 with valid data creates an item" do
      category = insert(:item_category)

      # simple case
      attrs = params_for(:aid_item)
      assert {:ok, %Item{} = item} = Aid.create_item(category, attrs)
      assert item.name == attrs.name
      assert item.category_id == category.id

      # also creates associations with mods
      mod1 = insert(:aid_mod)
      mod2 = insert(:aid_mod)
      attrs = params_for(:aid_item)
      attrs = %{attrs | mods: [mod1, mod2]}
      assert {:ok, %Item{} = item} = Aid.create_item(category, attrs)
      assert item.mods == [mod1, mod2]
    end

    # TODO: ensure each changeset has the right errors
    test "create_item/2 with invalid data returns an error changeset" do
      category = insert(:item_category)

      # too short
      attrs = params_for(:invalid_short_aid_item)
      assert {:error, %Ecto.Changeset{} = _changeset} = Aid.create_item(category, attrs)

      # too long
      attrs = params_for(:invalid_long_aid_item)
      assert {:error, %Ecto.Changeset{} = _changeset} = Aid.create_item(category, attrs)
    end

    # TODO: test moving items to a different category
    test "update_item/2 with valid data updates an item" do
      old_item = insert(:aid_item)
      attrs = params_for(:aid_item)

      assert {:ok, %Item{} = item} = Aid.update_item(old_item, attrs)
      assert item.name != old_item.name
      assert item.name == attrs.name

      # also creates / deletes associations with mods
      mod1 = insert(:aid_mod)
      mod2 = insert(:aid_mod)
      mod3 = insert(:aid_mod)
      old_item = insert(:aid_item, %{mods: [mod1, mod2]})

      attrs = params_for(:aid_item)
      attrs = %{attrs | mods: [mod2, mod3]}
      assert {:ok, %Item{} = item} = Aid.update_item(old_item, attrs)
      assert item.mods == [mod2, mod3]
    end

    # TODO: ensure each changeset has the right errors
    test "update_item/2 with invalid data returns error changeset" do
      item = insert(:aid_item)
      |> without_assoc([:category, :items], :many)
      |> without_assoc(:entries, :many)

      # too short
      attrs = params_for(:invalid_short_aid_item)
      assert {:error, %Ecto.Changeset{}} = Aid.update_item(item, attrs)
      assert item == Aid.get_item!(item.id)

      # too long
      attrs = params_for(:invalid_long_aid_item)
      assert {:error, %Ecto.Changeset{}} = Aid.update_item(item, attrs)
      assert item == Aid.get_item!(item.id)
    end

    test "delete_item/1 deletes an item that isn't referenced by any list entries" do
      # not referenced by entries
      item = insert(:aid_item)
      assert {:ok, %Item{}} = Aid.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Aid.get_item!(item.id) end

      # TODO: test that associations with mods are also delete
      #       (i.e. entries in the join table are also removed)
      #
      #       can possibly do this by getting a mod and ensuring that item
      #       doesn't show up in mod.items
    end

    test "delete_item/1 doesn't delete items that are referenced by list entries" do
      item = insert(:aid_item)
      |> without_assoc([:category, :items], :many)
      |> without_assoc(:entries, :many)

      _entry = insert(:list_entry, %{item: item})

      assert {:error, %Ecto.Changeset{}} = Aid.delete_item(item)
      assert item == Aid.get_item!(item.id)
      # TODO: getting an entry is still undefined
      # assert entry = Aid.get_entry!(entry.id)
    end
  end

  # Mod
  # ================================================================================
  describe "mods" do
    test "list_mods/0 returns all mods" do
      # none
      assert Aid.list_mods() == []

      # 1
      mod1 = insert(:aid_mod) |> without_assoc(:items, :many)
      assert Aid.list_mods() == [mod1]

      # many
      mod2 = insert(:aid_mod) |> without_assoc(:items, :many)
      assert Aid.list_mods() == [mod1, mod2]

      # ordered by name
      last_mod = insert(:aid_mod, %{name: "Z"}) |> without_assoc(:items, :many)
      first_mod = insert(:aid_mod, %{name: "A"}) |> without_assoc(:items, :many)
      assert Aid.list_mods() == [
        first_mod,
        mod1,
        mod2,
        last_mod
      ]
    end

    test "get_mod!/1 returns the requested mod" do
      mod = insert(:aid_mod)
      assert Aid.get_mod!(mod.id) == mod

      # with items and categories preloaded
      items = [insert(:aid_item), insert(:aid_item)]
      |> without_assoc(:entries, :many)
      |> without_assoc(:mods, :many)
      |> without_assoc([:category, :items], :many)
      mod = insert(:aid_mod, %{items: items})

      retrieved_mod = Aid.get_mod!(mod.id)
      assert retrieved_mod == mod
      assert length(retrieved_mod.items) == 2
    end

    test "get_mod!/1 with a non-existent id throws an error" do
      assert_raise Ecto.NoResultsError, ~r/^expected at least one result but got none in query/, fn ->
        Aid.get_mod!(1312)
      end
    end

    test "create_mod/1 with valid data creates a mod" do
      # integer mod
      attrs = params_for(:aid_mod, %{type: "integer"})
      assert {:ok, %Mod{} = mod} = Aid.create_mod(attrs)
      assert mod.name == attrs.name
      assert mod.description == attrs.description
      assert mod.type == attrs.type

      # integer mods should never have the "values" field set
      attrs = params_for(:aid_mod, %{type: "integer", values: ["not", "set"]})
      assert {:ok, %Mod{} = mod} = Aid.create_mod(attrs)
      assert mod.values == nil

      # select mod
      attrs = params_for(:aid_mod, %{type: "select"})
      assert {:ok, %Mod{} = mod} = Aid.create_mod(attrs)
      assert mod.name == attrs.name
      assert mod.description == attrs.description
      assert mod.type == attrs.type
      assert mod.values == attrs.values

      # multi-select mod
      attrs = params_for(:aid_mod, %{type: "multi-select"})
      assert {:ok, %Mod{} = mod} = Aid.create_mod(attrs)
      assert mod.name == attrs.name
      assert mod.description == attrs.description
      assert mod.type == attrs.type
      assert mod.values == attrs.values

      # also creates association with items
      item1 = insert(:aid_item)
      item2 = insert(:aid_item)
      attrs = params_for(:aid_mod)
      attrs = %{attrs | items: [item1, item2]} # TODO: handle this in the factory?
      assert {:ok, %Mod{} = mod} = Aid.create_mod(attrs)
      assert mod.items == [item1, item2]
    end

    # TODO: ensure each changeset has the right errors
    test "create_mod/1 with invalid data returns an error changeset" do
      # too short
      attrs = params_for(:invalid_short_aid_mod)
      assert {:error, %Ecto.Changeset{} = _changeset} = Aid.create_mod(attrs)

      # too long
      attrs = params_for(:invalid_long_aid_mod)
      assert {:error, %Ecto.Changeset{} = _changeset} = Aid.create_mod(attrs)

      # invalid type
      attrs = params_for(:invalid_type_aid_mod)
      assert {:error, %Ecto.Changeset{} = _changeset} = Aid.create_mod(attrs)

      # duplicate name
      # TODO: check unique constraints in other aid schema tests
      insert(:aid_mod, %{name: "the same"})
      attrs = params_for(:aid_mod, %{name: "the same"})
      assert {:error, %Ecto.Changeset{} = _changeset} = Aid.create_mod(attrs)
    end

    test "update_mod/2 with valid data updates a mod" do
      # basic fields
      old_mod = insert(:aid_mod)
      attrs = params_for(:aid_mod, %{type: old_mod.type, values: old_mod.values})

      assert {:ok, %Mod{} = mod} = Aid.update_mod(old_mod, attrs)
      assert mod.name != old_mod.name
      assert mod.name == attrs.name
      assert mod.description != old_mod.description
      assert mod.description == attrs.description
      assert mod.type == old_mod.type
      assert mod.values == old_mod.values

      # type change
      old_mod = insert(:aid_mod, %{type: "select", values: ["a", "b"]})
      attrs = params_for(:aid_mod, %{type: "multi-select", values: old_mod.values})

      assert {:ok, %Mod{} = mod} = Aid.update_mod(old_mod, attrs)
      assert mod.type != old_mod.type
      assert mod.type == attrs.type

      # values change
      old_mod = insert(:aid_mod, %{type: "select", values: ["a", "b"]})
      attrs = params_for(:aid_mod, %{type: old_mod.type, values: ["c" | old_mod.values]})

      assert {:ok, %Mod{} = mod} = Aid.update_mod(old_mod, attrs)
      assert mod.values != old_mod.values
      assert mod.values == attrs.values
      assert Enum.all?(old_mod.values, &(&1 in mod.values))

      # also creates / deletes associations with items
      item1 = insert(:aid_item)
      item2 = insert(:aid_item)
      item3 = insert(:aid_item)
      old_mod = insert(:aid_mod, %{items: [item1, item2]})
      attrs = params_for(:aid_mod, %{type: old_mod.type, values: old_mod.values})
      attrs = %{attrs | items: [item2, item3]}

      assert {:ok, %Mod{} = mod} = Aid.update_mod(old_mod, attrs)
      assert mod.items == [item2, item3]
    end

    # TODO: ensure each changeset has the right errors
    test "update_mod/2 with invalid data returns error changeset" do
      mod = insert(:aid_mod, %{type: "select"})

      # too short
      attrs = params_for(:invalid_short_aid_mod)
      assert {:error, %Ecto.Changeset{}} = Aid.update_mod(mod, attrs)
      assert mod == Aid.get_mod!(mod.id)

      # too long
      attrs = params_for(:invalid_long_aid_mod)
      assert {:error, %Ecto.Changeset{}} = Aid.update_mod(mod, attrs)
      assert mod == Aid.get_mod!(mod.id)

      # invalid type
      attrs = params_for(:invalid_type_aid_mod)
      assert {:error, %Ecto.Changeset{}} = Aid.update_mod(mod, attrs)
      assert mod == Aid.get_mod!(mod.id)

      # duplicate name
      insert(:aid_mod, %{name: "the same"})
      old_mod = insert(:aid_mod, %{name: "different"})
      attrs = params_for(:aid_mod, %{name: "the same", type: old_mod.type, values: old_mod.values})
      assert {:error, %Ecto.Changeset{} = _changeset} = Aid.create_mod(attrs)

      # invalid type change
      # TODO: test all change combos except select => multi-select?
      mod = insert(:aid_mod, %{type: "integer"})
      attrs = params_for(:aid_mod, %{type: "select"})
      assert {:error, %Ecto.Changeset{}} = Aid.update_mod(mod, attrs)
      assert mod == Aid.get_mod!(mod.id)

      # invalid values change
      mod = insert(:aid_mod, %{type: "select", values: ["a", "b", "c"]})
      attrs = params_for(:aid_mod, %{type: "select", values: ["a", "b"]})
      assert {:error, %Ecto.Changeset{}} = Aid.update_mod(mod, attrs)
      assert mod == Aid.get_mod!(mod.id)
    end

    test "delete_mod/1 deletes a mod that isn't referenced by any mod values" do
      mod = insert(:aid_mod)
      assert {:ok, %Mod{}} = Aid.delete_mod(mod)
      assert_raise Ecto.NoResultsError, fn -> Aid.get_mod!(mod.id) end

      # TODO: test that associations with mods are also delete
      #       (i.e. entries in the join table are also removed)
      #
      #       can possibly do this by getting an mod and ensuring that mod
      #       doesn't show up in item.mods
    end

    test "delete_mod/1 doesn't delete mods that are referenced by mod values" do
      mod = insert(:aid_mod)
      _mod_value = insert(:mod_value, %{mod: mod})

      assert {:error, %Ecto.Changeset{}} = Aid.delete_mod(mod)
      assert mod == Aid.get_mod!(mod.id)
      # TODO: getting an entry is still undefined
      # assert mod_value == Aid.get_mod_value!(mod_value.id)
    end
  end

end
