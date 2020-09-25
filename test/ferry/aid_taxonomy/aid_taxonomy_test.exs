defmodule Ferry.AidTaxonomyTest do
  use Ferry.DataCase

  alias Ferry.AidTaxonomy
  alias Ferry.AidTaxonomy.Item
  alias Ferry.AidTaxonomy.Category
  alias Ferry.AidTaxonomy.Mod

  # Category
  # ================================================================================

  describe "categories" do
    test "list_categories/0 returns all categories" do
      # none
      assert AidTaxonomy.list_categories() == []

      # 1
      category1 = insert(:aid_category, %{name: "M"})
      assert AidTaxonomy.list_categories() == [category1]

      # many
      category2 = insert(:aid_category, %{name: "N"})
      assert AidTaxonomy.list_categories() == [category1, category2]

      # ordered by name
      last_category = insert(:aid_category, %{name: "Z"})
      first_category = insert(:aid_category, %{name: "A"})

      assert(
        AidTaxonomy.list_categories() == [
          first_category,
          category1,
          category2,
          last_category
        ]
      )
    end

    test "get_category!/1 returns the requested category" do
      category = insert(:aid_category)
      assert AidTaxonomy.get_category!(category.id) == category

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
        |> without_assoc(:mods, :many)

      category = %{category | items: items}

      assert AidTaxonomy.get_category!(category.id) == category
    end

    test "get_category!/1 with a non-existent id throws an error" do
      assert_raise(
        Ecto.NoResultsError,
        ~r/^expected at least one result but got none in query/,
        fn ->
          AidTaxonomy.get_category!(1312)
        end
      )
    end

    test "create_category/1 with valid data creates a category" do
      attrs = params_for(:aid_category)
      assert {:ok, %Category{} = category} = AidTaxonomy.create_category(attrs)
      assert category.name == attrs.name
    end

    # TODO: ensure each changeset has the right errors
    test "create_category/1 with invalid data returns an error changeset" do
      # too short
      attrs = params_for(:invalid_short_aid_category)
      assert {:error, %Ecto.Changeset{} = _changeset} = AidTaxonomy.create_category(attrs)

      # too long
      attrs = params_for(:invalid_long_aid_category)
      assert {:error, %Ecto.Changeset{} = _changeset} = AidTaxonomy.create_category(attrs)
    end

    test "update_category/2 with valid data updates a category" do
      old_category = insert(:aid_category) |> with_item() |> with_item()
      attrs = params_for(:aid_category)

      assert {:ok, %Category{} = category} = AidTaxonomy.update_category(old_category, attrs)

      assert category.name != old_category.name
      assert category.name == attrs.name

      # item list shouldn't change
      assert category.items == old_category.items
    end

    # TODO: ensure each changeset has the right errors
    test "update_category/2 with invalid data returns error changeset" do
      category = insert(:aid_category)

      # too short
      attrs = params_for(:invalid_short_aid_category)
      assert {:error, %Ecto.Changeset{}} = AidTaxonomy.update_category(category, attrs)
      assert category == AidTaxonomy.get_category!(category.id)

      # too long
      attrs = params_for(:invalid_long_aid_category)
      assert {:error, %Ecto.Changeset{}} = AidTaxonomy.update_category(category, attrs)
      assert category == AidTaxonomy.get_category!(category.id)
    end

    test "update_category/2 on unknown category raises an error" do
      attrs = params_for(:aid_category)

      assert_raise(Ecto.StaleEntryError, fn ->
        AidTaxonomy.update_category(%Category{id: 123}, attrs)
      end)
    end

    test "delete_category/1 deletes a category that isn't referenced by any list entries" do
      # not referenced by items
      category = insert(:aid_category)
      assert {:ok, %Category{}} = AidTaxonomy.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> AidTaxonomy.get_category!(category.id) end

      # referenced by items that aren't referenced by list entries
      category = insert(:aid_category) |> with_item() |> with_item()
      assert {:ok, %Category{}} = AidTaxonomy.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> AidTaxonomy.get_category!(category.id) end

      # the items should be deleted as well
      assert_raise Ecto.NoResultsError, fn ->
        AidTaxonomy.get_item!(Enum.at(category.items, 0).id)
      end

      assert_raise Ecto.NoResultsError, fn ->
        AidTaxonomy.get_item!(Enum.at(category.items, 1).id)
      end
    end

    test "delete_category/1 doesn't delete categories that are referenced by list entries" do
      category = insert(:aid_category)
      item = insert(:aid_item, %{category: category})
      _entry = insert(:entry, %{item: item})

      assert {:error, %Ecto.Changeset{}} = AidTaxonomy.delete_category(category)
      assert category.name == AidTaxonomy.get_category!(category.id).name
      assert item.name == AidTaxonomy.get_item!(item.id).name
      # TODO: getting an entry is still undefined
      # assert entry = AidTaxonomy.get_entry!(entry.id)
    end
  end

  # Item
  # ================================================================================
  describe "items" do
    test "get_item!/1 returns the requested item" do
      # no mods
      item = insert(:aid_item)
      retrieved_item = AidTaxonomy.get_item!(item.id)
      assert retrieved_item == item |> without_assoc([:category, :items], :many)
      assert %Category{} = retrieved_item.category
      assert retrieved_item.mods == []

      # with mods preloaded in order
      mod1 = insert(:aid_mod, %{name: "Z"})
      mod2 = insert(:aid_mod, %{name: "A"})
      mod3 = insert(:aid_mod, %{name: "M"})
      item = insert(:aid_item, %{mods: [mod1, mod2, mod3]})
      retrieved_item = AidTaxonomy.get_item!(item.id)
      assert retrieved_item.mods == [mod2, mod3, mod1]
    end

    test "get_item!/1 with a non-existent id throws an error" do
      assert_raise(
        Ecto.NoResultsError,
        ~r/^expected at least one result but got none in query/,
        fn ->
          AidTaxonomy.get_item!(1312)
        end
      )
    end

    test "create_item/2 with valid data creates an item" do
      category = insert(:aid_category)

      # simple case
      attrs = params_for(:aid_item)
      assert {:ok, %Item{} = item} = AidTaxonomy.create_item(category, attrs)
      assert item.name == attrs.name
      assert item.category_id == category.id

      # name can be the same across categories
      category2 = insert(:aid_category)
      item1 = insert(:aid_item, %{name: "SAME", category: category})
      attrs = params_for(:aid_item, %{name: "SAME", category: category2})
      assert {:ok, %Item{} = item2} = AidTaxonomy.create_item(category2, attrs)
      assert item1.name == item2.name
      assert item1.category != item2.category

      # doesn't need mods...
      attrs = params_for(:aid_item, %{mods: nil})
      assert {:ok, %Item{} = item} = AidTaxonomy.create_item(category, attrs)

      # ... but also creates associations with mods
      mod1 = insert(:aid_mod)
      mod2 = insert(:aid_mod)
      attrs = params_for(:aid_item)
      attrs = %{attrs | mods: [mod1, mod2]}
      assert {:ok, %Item{} = item} = AidTaxonomy.create_item(category, attrs)
      assert item.mods == [mod1, mod2]
    end

    # TODO: ensure each changeset has the right errors
    test "create_item/2 with invalid data returns an error changeset" do
      category = insert(:aid_category)

      # too short
      attrs = params_for(:invalid_short_aid_item)
      assert {:error, %Ecto.Changeset{} = _changeset} = AidTaxonomy.create_item(category, attrs)

      # too long
      attrs = params_for(:invalid_long_aid_item)
      assert {:error, %Ecto.Changeset{} = _changeset} = AidTaxonomy.create_item(category, attrs)

      # name must be different within a category
      insert(:aid_item, %{name: "SAME", category: category})
      attrs = params_for(:aid_item, %{name: "SAME", category: category})
      assert {:error, %Ecto.Changeset{} = _changeset} = AidTaxonomy.create_item(category, attrs)
    end

    # TODO: test moving items to a different category
    test "update_item/2 with valid data updates an item" do
      old_item = insert(:aid_item)
      attrs = params_for(:aid_item)

      assert {:ok, %Item{} = item} = AidTaxonomy.update_item(old_item, attrs)
      assert item.name != old_item.name
      assert item.name == attrs.name

      # name can be the same across categories
      category1 = insert(:aid_category)
      category2 = insert(:aid_category)
      item1 = insert(:aid_item, %{name: "SAME", category: category1})
      item2 = insert(:aid_item, %{name: "DIFFERENT", category: category2})
      attrs = params_for(:aid_item, %{name: "SAME", category: category2})
      assert {:ok, %Item{} = item2} = AidTaxonomy.update_item(item2, attrs)
      assert item1.name == item2.name
      assert item1.category != item2.category

      # doesn't need mods...
      old_item = insert(:aid_item, %{mods: []})
      attrs = params_for(:aid_item, %{mods: nil})
      assert {:ok, %Item{} = mod} = AidTaxonomy.update_item(old_item, attrs)

      # ... but also creates / deletes associations with mods
      mod1 = insert(:aid_mod)
      mod2 = insert(:aid_mod)
      mod3 = insert(:aid_mod)
      old_item = insert(:aid_item, %{mods: [mod1, mod2]})

      attrs = params_for(:aid_item)
      attrs = %{attrs | mods: [mod2, mod3]}
      assert {:ok, %Item{} = item} = AidTaxonomy.update_item(old_item, attrs)
      assert item.mods == [mod2, mod3]
    end

    # TODO: ensure each changeset has the right errors
    test "update_item/2 with invalid data returns error changeset" do
      item = insert(:aid_item) |> without_assoc([:category, :items], :many)
      # too short
      attrs = params_for(:invalid_short_aid_item)
      assert {:error, %Ecto.Changeset{}} = AidTaxonomy.update_item(item, attrs)
      assert item == AidTaxonomy.get_item!(item.id)

      # too long
      attrs = params_for(:invalid_long_aid_item)
      assert {:error, %Ecto.Changeset{}} = AidTaxonomy.update_item(item, attrs)
      assert item == AidTaxonomy.get_item!(item.id)

      # name must be different within a category
      category = insert(:aid_category)
      _item1 = insert(:aid_item, %{name: "SAME", category: category})

      item2 =
        insert(:aid_item, %{name: "DIFFERENT", category: category})
        |> without_assoc([:category, :items], :many)

      attrs = params_for(:aid_item, %{name: "SAME", category: category})
      assert {:error, %Ecto.Changeset{} = _changeset} = AidTaxonomy.update_item(item2, attrs)
      assert item2 == AidTaxonomy.get_item!(item2.id)
    end

    test "delete_item/1 deletes an item that isn't referenced by any list entries" do
      # not referenced by entries
      item = insert(:aid_item)
      assert {:ok, %Item{}} = AidTaxonomy.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> AidTaxonomy.get_item!(item.id) end

      # TODO: test that associations with mods are also delete
      #       (i.e. entries in the join table are also removed)
      #
      #       can possibly do this by getting a mod and ensuring that item
      #       doesn't show up in mod.items
    end

    test "delete_item/1 doesn't delete items that are referenced by list entries" do
      item = insert(:aid_item) |> without_assoc([:category, :items], :many)
      _entry = insert(:entry, %{item: item})

      assert {:error, %Ecto.Changeset{}} = AidTaxonomy.delete_item(item)
      assert item == AidTaxonomy.get_item!(item.id)
      # TODO: getting an entry is still undefined
      # assert entry = AidTaxonomy.get_entry!(entry.id)
    end
  end

  # Mod
  # ================================================================================
  describe "mods" do
    test "list_mods/0 returns all mods" do
      # none
      assert AidTaxonomy.list_mods() == []

      # 1
      mod1 = insert(:aid_mod)
      assert AidTaxonomy.list_mods() == [mod1]

      # many
      mod2 = insert(:aid_mod)
      assert AidTaxonomy.list_mods() == [mod1, mod2]

      # ordered by name
      last_mod = insert(:aid_mod, %{name: "Z"})
      first_mod = insert(:aid_mod, %{name: "A"})

      assert AidTaxonomy.list_mods() == [
               first_mod,
               mod1,
               mod2,
               last_mod
             ]
    end

    test "get_mod!/1 returns the requested mod" do
      mod = insert(:aid_mod)
      assert AidTaxonomy.get_mod!(mod.id) == mod
    end

    test "get_mod!/1 with a non-existent id throws an error" do
      assert_raise(
        Ecto.NoResultsError,
        ~r/^expected at least one result but got none in query/,
        fn ->
          AidTaxonomy.get_mod!(1312)
        end
      )
    end

    test "create_mod/1 with valid data creates a mod" do
      # integer mod
      attrs = params_for(:aid_mod, %{type: "integer", description: "test"})

      assert {:ok, %Mod{} = mod} = AidTaxonomy.create_mod(attrs)
      assert mod.name == attrs.name
      assert mod.description == attrs.description
      assert mod.type == attrs.type
    end

    # TODO: ensure each changeset has the right errors
    test "create_mod/1 with invalid data returns an error changeset" do
      # too short
      attrs = params_for(:invalid_short_aid_mod)
      assert {:error, %Ecto.Changeset{} = _changeset} = AidTaxonomy.create_mod(attrs)

      # too long
      attrs = params_for(:invalid_long_aid_mod)
      assert {:error, %Ecto.Changeset{} = _changeset} = AidTaxonomy.create_mod(attrs)

      # invalid type
      attrs = params_for(:invalid_type_aid_mod)
      assert {:error, %Ecto.Changeset{} = _changeset} = AidTaxonomy.create_mod(attrs)

      # duplicate name
      # TODO: check unique constraints in other aid schema tests
      insert(:aid_mod, %{name: "the same"})
      attrs = params_for(:aid_mod, %{name: "the same"})
      assert {:error, %Ecto.Changeset{} = _changeset} = AidTaxonomy.create_mod(attrs)
    end

    test "update_mod/2 with valid data updates a mod" do
      # basic fields
      old_mod = insert(:aid_mod)
      attrs = params_for(:aid_mod, %{type: old_mod.type})

      assert {:ok, %Mod{} = mod} = AidTaxonomy.update_mod(old_mod, attrs)
      assert mod.name != old_mod.name
      assert mod.name == attrs.name
      assert mod.description != old_mod.description
      assert mod.description == attrs.description
      assert mod.type == old_mod.type

      # type change
      old_mod = insert(:aid_mod, %{type: "select"})
      attrs = params_for(:aid_mod, %{type: "multi-select"})

      assert {:ok, %Mod{} = mod} = AidTaxonomy.update_mod(old_mod, attrs)
      assert mod.type != old_mod.type
      assert mod.type == attrs.type
    end

    # TODO: ensure each changeset has the right errors
    test "update_mod/2 with invalid data returns error changeset" do
      mod = insert(:aid_mod, %{type: "select"})

      # too short
      attrs = params_for(:invalid_short_aid_mod)
      assert {:error, %Ecto.Changeset{}} = AidTaxonomy.update_mod(mod, attrs)
      assert mod == AidTaxonomy.get_mod!(mod.id)

      # too long
      attrs = params_for(:invalid_long_aid_mod)
      assert {:error, %Ecto.Changeset{}} = AidTaxonomy.update_mod(mod, attrs)
      assert mod == AidTaxonomy.get_mod!(mod.id)

      # invalid type
      attrs = params_for(:invalid_type_aid_mod)
      assert {:error, %Ecto.Changeset{}} = AidTaxonomy.update_mod(mod, attrs)
      assert mod == AidTaxonomy.get_mod!(mod.id)

      # duplicate name
      insert(:aid_mod, %{name: "the same"})
      old_mod = insert(:aid_mod, %{name: "different"})

      attrs = params_for(:aid_mod, %{name: "the same", type: old_mod.type})

      assert {:error, %Ecto.Changeset{} = _changeset} = AidTaxonomy.create_mod(attrs)
    end

    test "delete_mod/1 deletes a mod that isn't referenced by any mod values" do
      mod = insert(:aid_mod)
      assert {:ok, %Mod{}} = AidTaxonomy.delete_mod(mod)
      assert_raise Ecto.NoResultsError, fn -> AidTaxonomy.get_mod!(mod.id) end

      # TODO: test that items that reference the mod aren't deleted

      # TODO: test that associations with mods are also delete
      #       (i.e. entries in the join table are also removed)
      #
      #       can possibly do this by getting an mod and ensuring that mod
      #       doesn't show up in item.mods
    end

    test "delete_mod/1 doesn't delete mods that are referenced by mod values" do
      mod = insert(:aid_mod)
      _mod_value = insert(:mod_value, %{mod: mod})

      assert {:error, %Ecto.Changeset{}} = AidTaxonomy.delete_mod(mod)
      assert mod == AidTaxonomy.get_mod!(mod.id)
      # TODO: getting an entry is still undefined
      # assert mod_value == AidTaxonomy.get_mod_value!(mod_value.id)
    end
  end
end
