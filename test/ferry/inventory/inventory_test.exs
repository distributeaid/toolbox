defmodule Ferry.InventoryTest do
  use Ferry.DataCase

  alias Ferry.Profiles
  alias Ferry.Inventory
  alias Ferry.Inventory.{
    Category,
    Item,
    InventoryListControls,
    Mod,
    Packaging,
    Stock
  }


  # Inventory List
  # ================================================================================
  # TODO: test control_data & controls

  describe "inventory list" do
    test "get_inventory_list/1 with no controls set returns all stocks in the results" do
      # group 1
      group1 = insert(:group)
      project1 = insert(:project, %{group: group1})
      project2 = insert(:project, %{group: group1})

      # group 2
      group2 = insert(:group)
      project3 = insert(:project, %{group: group2})

      # no stock
      %{results: results} = Inventory.get_inventory_list()
      assert results == []

      # 1 stock, 1 project, 1 group
      stock1 = insert(:stock, %{project: project1})
      %{results: results} = Inventory.get_inventory_list()
      assert results == [stock1]

      # n stock, 1 project, 1 group
      stock2 = insert(:stock, %{project: project1})
      %{results: results} = Inventory.get_inventory_list()
      assert results == [stock1, stock2]

      # n stock, n projects, 1 group
      stock3 = insert(:stock, %{project: project2})
      %{results: results} = Inventory.get_inventory_list()
      assert results == [stock1, stock2, stock3]

      # n stock, n projects, n groups
      stock4 = insert(:stock, %{project: project3})
      %{results: results} = Inventory.get_inventory_list()
      assert results == [stock1, stock2, stock3, stock4]
    end

    test "get_inventory_list/1 with the group filter set returns all stock for the selected groups" do
      # group 1
      group1 = insert(:group)
      project1 = insert(:project, %{group: group1})
      project2 = insert(:project, %{group: group1})
      stock1 = insert(:stock, %{project: project1})
      stock2 = insert(:stock, %{project: project2})

      # group 2
      group2 = insert(:group)
      project3 = insert(:project, %{group: group2})
      stock3 = insert(:stock, %{project: project3})

      # group 3
      group3 = insert(:group)
      project4 = insert(:project, %{group: group3})
      stock4 = insert(:stock, %{project: project4})

      # group 4 - has no stock
      group4 = insert(:group)
      _project5 = insert(:project, %{group: group4})

      # no group selected- list all stock
      controls = %{group_filter: []}
      %{results: results} = Inventory.get_inventory_list(controls)
      assert results == [stock1, stock2, stock3, stock4]

      # 1 group selected
      controls = %{group_filter: [group1.id]}
      %{results: results} = Inventory.get_inventory_list(controls)
      assert results == [stock1, stock2]

      # some groups selected
      controls = %{group_filter: [group1.id, group2.id]}
      %{results: results} = Inventory.get_inventory_list(controls)
      assert results == [stock1, stock2, stock3]

      # all groups selected
      controls = %{group_filter: [group1.id, group2.id, group3.id, group4.id]}
      %{results: results} = Inventory.get_inventory_list(controls)
      assert results == [stock1, stock2, stock3, stock4]

      # group without stock selected
      controls = %{group_filter: [group4.id]}
      %{results: results} = Inventory.get_inventory_list(controls)
      assert results == []
    end
  end


  # Categories
  # ================================================================================

  describe "categories" do
    test "list_top_categories/1 returns the top n categories" do
      # no categories
      assert Inventory.list_top_categories() == []

      # <= n categories
      stock1 = insert(:stock)
      item = insert(:item)
      stock2 = insert(:stock, %{item: item})
      _ = insert(:stock, %{item: item}) # just adds more stock entries for that category
      categories = Inventory.list_top_categories(3)
      assert Enum.at(categories, 0).id == stock2.item.category.id
      assert Enum.at(categories, 0).count == 2
      assert Enum.at(categories, 1).id == stock1.item.category.id
      assert Enum.at(categories, 1).count == 1

      # > n categories
      stock3 = insert(:stock)
      _stock4 = insert(:stock)
      categories = Inventory.list_top_categories(3)
      assert Enum.at(categories, 0).id == stock2.item.category.id
      assert Enum.at(categories, 0).count == 2
      assert Enum.at(categories, 1).id == stock1.item.category.id
      assert Enum.at(categories, 1).count == 1
      assert Enum.at(categories, 2).id == stock3.item.category.id
      assert Enum.at(categories, 2).count == 1
    end
  end

  # Categories
  # ================================================================================

  describe "items" do
    test "list_top_items/1 returns the top n items" do
      # no items
      assert Inventory.list_top_items() == []

      # <= n items
      stock1 = insert(:stock)
      item = insert(:item)
      stock2 = insert(:stock, %{item: item})
      _ = insert(:stock, %{item: item}) # just adds more stock entries for that item
      items = Inventory.list_top_items(3)
      assert Enum.at(items, 0).id == stock2.item.id
      assert Enum.at(items, 0).count == 2
      assert Enum.at(items, 1).id == stock1.item.id
      assert Enum.at(items, 1).count == 1

      # > n items
      stock3 = insert(:stock)
      _stock4 = insert(:stock)
      items = Inventory.list_top_items(3)
      assert Enum.at(items, 0).id == stock2.item.id
      assert Enum.at(items, 0).count == 2
      assert Enum.at(items, 1).id == stock1.item.id
      assert Enum.at(items, 1).count == 1
      assert Enum.at(items, 2).id == stock3.item.id
      assert Enum.at(items, 2).count == 1
    end
  end

  # Stocks
  # ================================================================================
  describe "stocks" do

    # Helpers
    # ------------------------------------------------------------
    
    # NOTE: ExMachina isn't setup to build params for parent objects defined
    #       through a `belongs_to` field, so we need to make a helper function
    #       to do the equivalent.
    #
    # TODO: Make this generic and extend ExMachina  Perhaps try to merge the
    #       changes upstream?
    defp deep_params_for_stock(attrs \\ %{}) do
      project = insert(:project)
      assoc_params = %{
        "project_id" => project.id,
        "item" => Map.put(string_params_for(:item), "category", string_params_for(:category)),
        "mod" => string_params_for(:mod),
        "packaging" => string_params_for(:packaging)
      }
      deep_params = Enum.into(assoc_params, string_params_for(:stock))
      _overridden_params = Enum.into(attrs, deep_params)
    end

    # Tests
    # ------------------------------------------------------------

    # test "list_stocks/0 returns all stocks" do
    #   stock = stock_fixture()
    #   assert Inventory.list_stocks() == [stock]
    # end

    test "get_stock!/1 returns the stock with given id" do
      stock = insert(:stock)
      assert Inventory.get_stock!(stock.id) == stock
    end

    test "get_stock!/1 with a non-existent id throws an error" do
      assert_raise Ecto.NoResultsError, ~r/^expected at least one result but got none in query/, fn ->
        Inventory.get_stock!(1312)
      end
    end

    test "create_stock/1 with valid new data creates a stock entry" do
      attrs = deep_params_for_stock()

      assert {:ok, %Stock{} = stock} = Inventory.create_stock(attrs)
      assert stock.count == attrs["count"]
      assert stock.description == attrs["description"]
      # TODO: test stock.photo

      assert stock.project_id == attrs["project_id"]

      assert %Item{} = stock.item
      assert stock.item.name == attrs["item"]["name"]

      assert %Category{} = stock.item.category
      assert stock.item.category.name == attrs["item"]["category"]["name"]

      assert %Mod{} = stock.mod
      assert stock.mod.gender == attrs["mod"]["gender"] || (stock.mod.gender == nil && attrs["mod"]["gender"] == "")
      assert stock.mod.age == attrs["mod"]["age"] || (stock.mod.age == nil && attrs["mod"]["age"] == "")
      assert stock.mod.size == attrs["mod"]["size"] || (stock.mod.size == nil && attrs["mod"]["size"] == "")
      assert stock.mod.season == attrs["mod"]["season"] || (stock.mod.season == nil && attrs["mod"]["season"] == "")

      assert %Packaging{} = stock.packaging
      assert stock.packaging.count == attrs["packaging"]["count"]
      assert stock.packaging.type == attrs["packaging"]["type"]
      assert stock.packaging.description == attrs["packaging"]["description"]
      # TODO: test stock.packaging.photo
    end

    test "create_stock/1 with valid existing data creates a stock entry" do
      project = insert(:project)
      item = insert(:item) # NOTE: a category is inserted by the item factory
      attrs = deep_params_for_stock(%{
        "project_id" => project.id,
        "item" => %{
          "name" => item.name,
          "category" => %{"name" => item.category.name}
        },
        "mod" => string_params_for(:mod)
      })

      assert {:ok, %Stock{} = stock} = Inventory.create_stock(attrs)
      assert stock.count == attrs["count"]
      assert stock.description == attrs["description"]
      # TODO: test stock.photo

      assert stock.project_id == attrs["project_id"]

      assert %Item{} = stock.item
      assert stock.item.name == attrs["item"]["name"]

      assert %Category{} = stock.item.category
      assert stock.item.category.name == attrs["item"]["category"]["name"]

      assert %Mod{} = stock.mod
      assert stock.mod.gender == attrs["mod"]["gender"] || (stock.mod.gender == nil && attrs["mod"]["gender"] == "")
      assert stock.mod.age == attrs["mod"]["age"] || (stock.mod.age == nil && attrs["mod"]["age"] == "")
      assert stock.mod.size == attrs["mod"]["size"] || (stock.mod.size == nil && attrs["mod"]["size"] == "")
      assert stock.mod.season == attrs["mod"]["season"] || (stock.mod.season == nil && attrs["mod"]["season"] == "")

      assert %Packaging{} = stock.packaging
      assert stock.packaging.count == attrs["packaging"]["count"]
      assert stock.packaging.type == attrs["packaging"]["type"]
      assert stock.packaging.description == attrs["packaging"]["description"]
      # TODO: test stock.packaging.photo
    end

    test "create_stock/1 with invalid data returns error changeset" do
      project = insert(:project)

      # is nil
      nil_attrs = deep_params_for_stock()
      nil_attrs = Map.put(nil_attrs, "project_id", nil)
      assert {:error, %Ecto.Changeset{} = changeset} = Inventory.create_stock(nil_attrs)
      assert 1 == length(changeset.errors)

      # too short
      assoc_params = %{
        "project_id" => project.id,
        "item" => Map.put(string_params_for(:invalid_short_item), "category", string_params_for(:invalid_short_category)),
        "mod" => string_params_for(:mod),
        "packaging" => string_params_for(:invalid_short_packaging)
      }
      short_attrs = Enum.into(assoc_params, string_params_for(:invalid_short_stock))
      assert {:error, %Ecto.Changeset{} = changeset} = Inventory.create_stock(short_attrs)
      errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, _} -> msg end)
      assert 1 == length(errors[:count])
      assert 1 == length(errors[:item][:name])
      assert 1 == length(errors[:item][:category][:name])
      assert 1 == length(errors[:packaging][:count])
      assert 1 == length(errors[:packaging][:type])

      # too long
      assoc_params = %{
        "project_id" => project.id,
        "item" => Map.put(string_params_for(:invalid_long_item), "category", string_params_for(:invalid_long_item)),
        "mod" => string_params_for(:mod),
        "packaging" => string_params_for(:packaging)
      }
      long_attrs = Enum.into(assoc_params, string_params_for(:stock))
      assert {:error, %Ecto.Changeset{} = changeset} = Inventory.create_stock(long_attrs)
      assert 1 == length(errors[:item][:name])
      assert 1 == length(errors[:item][:category][:name])
    end

    test "update_stock/2 with valid new data updates the stock" do
      current_stock = insert(:stock)
      attrs = deep_params_for_stock()

      assert {:ok, %Stock{} = stock} = Inventory.update_stock(current_stock, attrs)
      assert stock.count == attrs["count"]
      assert stock.description == attrs["description"]
      # TODO: test stock.photo

      assert stock.project_id == attrs["project_id"]

      assert %Item{} = stock.item
      assert stock.item.name == attrs["item"]["name"]

      assert %Category{} = stock.item.category
      assert stock.item.category.name == attrs["item"]["category"]["name"]

      assert %Mod{} = stock.mod
      assert stock.mod.gender == attrs["mod"]["gender"] || (stock.mod.gender == nil && attrs["mod"]["gender"] == "")
      assert stock.mod.age == attrs["mod"]["age"] || (stock.mod.age == nil && attrs["mod"]["age"] == "")
      assert stock.mod.size == attrs["mod"]["size"] || (stock.mod.size == nil && attrs["mod"]["size"] == "")
      assert stock.mod.season == attrs["mod"]["season"] || (stock.mod.season == nil && attrs["mod"]["season"] == "")

      assert %Packaging{} = stock.packaging
      assert stock.packaging.count == attrs["packaging"]["count"]
      assert stock.packaging.type == attrs["packaging"]["type"]
      assert stock.packaging.description == attrs["packaging"]["description"]
      # TODO: test stock.packaging.photo
    end

    test "update_stock/2 with valid existing data updates the stock" do
      current_stock = insert(:stock)

      project = insert(:project)
      item = insert(:item) # NOTE: a category is inserted by the item factory
      attrs = deep_params_for_stock(%{
        "project_id" => project.id,
        "item" => %{
          "name" => item.name,
          "category" => %{"name" => item.category.name}
        },
        "mod" => string_params_for(:mod)
      })

      assert {:ok, %Stock{} = stock} = Inventory.update_stock(current_stock, attrs)
      assert stock.count == attrs["count"]
      assert stock.description == attrs["description"]
      # TODO: test stock.photo

      assert stock.project_id == attrs["project_id"]

      assert %Item{} = stock.item
      assert stock.item.name == attrs["item"]["name"]

      assert %Category{} = stock.item.category
      assert stock.item.category.name == attrs["item"]["category"]["name"]

      assert %Mod{} = stock.mod
      assert stock.mod.gender == attrs["mod"]["gender"] || (stock.mod.gender == nil && attrs["mod"]["gender"] == "")
      assert stock.mod.age == attrs["mod"]["age"] || (stock.mod.age == nil && attrs["mod"]["age"] == "")
      assert stock.mod.size == attrs["mod"]["size"] || (stock.mod.size == nil && attrs["mod"]["size"] == "")
      assert stock.mod.season == attrs["mod"]["season"] || (stock.mod.season == nil && attrs["mod"]["season"] == "")

      assert %Packaging{} = stock.packaging
      assert stock.packaging.count == attrs["packaging"]["count"]
      assert stock.packaging.type == attrs["packaging"]["type"]
      assert stock.packaging.description == attrs["packaging"]["description"]
      # TODO: test stock.packaging.photo
    end

    test "update_stock/2 with invalid data returns error changeset" do
      # TODO: shouldn't be able to change project of a stock
      current_stock = insert(:stock)

      # is nil
      nil_attrs = deep_params_for_stock()
      nil_attrs = Map.put(nil_attrs, "project_id", nil)
      assert {:error, %Ecto.Changeset{} = changeset} = Inventory.update_stock(current_stock, nil_attrs)
      assert 1 == length(changeset.errors)

      # too short
      assoc_params = %{
        "item" => Map.put(string_params_for(:invalid_short_item), "category", string_params_for(:invalid_short_category)),
        "mod" => string_params_for(:mod),
        "packaging" => string_params_for(:invalid_short_packaging)
      }
      short_attrs = Enum.into(assoc_params, string_params_for(:invalid_short_stock))
      assert {:error, %Ecto.Changeset{} = changeset} = Inventory.update_stock(current_stock, short_attrs)
      errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, _} -> msg end)
      assert 1 == length(errors[:count])
      assert 1 == length(errors[:item][:name])
      assert 1 == length(errors[:item][:category][:name])
      assert 1 == length(errors[:packaging][:count])
      assert 1 == length(errors[:packaging][:type])

      # too long
      assoc_params = %{
        "item" => Map.put(string_params_for(:invalid_long_item), "category", string_params_for(:invalid_long_item)),
        "mod" => string_params_for(:mod),
        "packaging" => string_params_for(:packaging)
      }
      long_attrs = Enum.into(assoc_params, string_params_for(:stock))
      assert {:error, %Ecto.Changeset{} = changeset} = Inventory.update_stock(current_stock, long_attrs)
      assert 1 == length(errors[:item][:name])
      assert 1 == length(errors[:item][:category][:name])
    end

    test "delete_stock/1 deletes the stock and packaging, but not the rest of the associations" do
      stock = insert(:stock)
      assert {:ok, %{
        stock: %Stock{} = stock,
        packaging: %Packaging{} = packaging,
      }} = Inventory.delete_stock(stock)

      # stock & packaging should be deleted, as identifiable data
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_stock!(stock.id) end
      assert_raise Ecto.NoResultsError, fn -> Repo.get!(Packaging, packaging.id) end

      # other associations should still exist
      project = Profiles.get_project!(stock.project.id) |> Repo.preload(:group)
      assert project == stock.project

      item = Repo.get(Item, stock.item.id) |> Repo.preload(:category)
      assert item == stock.item

      category = Repo.get(Category, stock.item.category.id)
      assert category == stock.item.category

      mod = Repo.get(Mod, stock.mod.id)
      assert mod == stock.mod
    end

    test "change_stock/1 returns a stock changeset" do
      stock = insert(:stock)
      assert %Ecto.Changeset{} = Inventory.change_stock(stock)
    end
  end
end
