defmodule Ferry.InventoryTest do
  use Ferry.DataCase

  alias Ferry.Profiles
  alias Ferry.Profiles.Project
  alias Ferry.Inventory
  alias Ferry.Inventory.{
    Category,
    Item,
    Mod,
    Packaging,
    Stock
  }

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
        project_id: project.id,
        item: Map.put(params_for(:item), :category, params_for(:category)),
        mod: params_for(:mod),
        packaging: params_for(:packaging)
      }
      deep_params = Enum.into(assoc_params, params_for(:stock))
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
      assert stock.count == attrs.count
      assert stock.description == attrs.description
      # TODO: test stock.photo

      assert stock.project_id == attrs.project_id

      assert %Item{} = stock.item
      assert stock.item.name == attrs.item.name

      assert %Category{} = stock.item.category
      assert stock.item.category.name == attrs.item.category.name

      assert %Mod{} = stock.mod
      assert stock.mod.gender == attrs.mod.gender || (stock.mod.gender == nil && attrs.mod.gender == "")
      assert stock.mod.age == attrs.mod.age || (stock.mod.age == nil && attrs.mod.age == "")
      assert stock.mod.size == attrs.mod.size || (stock.mod.size == nil && attrs.mod.size == "")
      assert stock.mod.season == attrs.mod.season || (stock.mod.season == nil && attrs.mod.season == "")

      assert %Packaging{} = stock.packaging
      assert stock.packaging.count == attrs.packaging.count
      assert stock.packaging.type == attrs.packaging.type
      assert stock.packaging.description == attrs.packaging.description
      # TODO: test stock.packaging.photo
    end

    test "create_stock/1 with valid existing data creates a stock entry" do
      attrs = deep_params_for_stock(%{
        project: insert(:project),
        item: insert(:item), # NOTE: a category is inserted by the item factory
        mod: build(:mod) # NOTE: mods already exist in the DB
      })

      assert {:ok, %Stock{} = stock} = Inventory.create_stock(attrs)
      assert stock.count == attrs.count
      assert stock.description == attrs.description
      # TODO: test stock.photo

      assert stock.project_id == attrs.project_id

      assert %Item{} = stock.item
      assert stock.item.name == attrs.item.name

      assert %Category{} = stock.item.category
      assert stock.item.category.name == attrs.item.category.name

      assert %Mod{} = stock.mod
      assert stock.mod.gender == attrs.mod.gender || (stock.mod.gender == nil && attrs.mod.gender == "")
      assert stock.mod.age == attrs.mod.age || (stock.mod.age == nil && attrs.mod.age == "")
      assert stock.mod.size == attrs.mod.size || (stock.mod.size == nil && attrs.mod.size == "")
      assert stock.mod.season == attrs.mod.season || (stock.mod.season == nil && attrs.mod.season == "")

      assert %Packaging{} = stock.packaging
      assert stock.packaging.count == attrs.packaging.count
      assert stock.packaging.type == attrs.packaging.type
      assert stock.packaging.description == attrs.packaging.description
      # TODO: test stock.packaging.photo
    end

    test "create_stock/1 with invalid data returns error changeset" do
      project = insert(:project)

      # is nil
      nil_attrs = deep_params_for_stock()
      nil_attrs = Map.put(nil_attrs, :project_id, nil)
      assert {:error, %Ecto.Changeset{} = changeset} = Inventory.create_stock(nil_attrs)
      assert 1 == length(changeset.errors)

      # too short
      assoc_params = %{
        project_id: project.id,
        item: Map.put(params_for(:invalid_short_item), :category, params_for(:invalid_short_category)),
        mod: params_for(:mod),
        packaging: params_for(:invalid_short_packaging)
      }
      short_attrs = Enum.into(assoc_params, params_for(:invalid_short_stock))
      assert {:error, %Ecto.Changeset{} = changeset} = Inventory.create_stock(short_attrs)
      errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, _} -> msg end)
      assert 1 == length(errors[:count])
      assert 1 == length(errors[:item][:name])
      assert 1 == length(errors[:item][:category][:name])
      assert 1 == length(errors[:packaging][:count])
      assert 1 == length(errors[:packaging][:type])

      # too long
      assoc_params = %{
        project_id: project.id,
        item: Map.put(params_for(:invalid_long_item), :category, params_for(:invalid_long_item)),
        mod: params_for(:mod),
        packaging: params_for(:packaging)
      }
      long_attrs = Enum.into(assoc_params, params_for(:stock))
      assert {:error, %Ecto.Changeset{} = changeset} = Inventory.create_stock(long_attrs)
      assert 1 == length(errors[:item][:name])
      assert 1 == length(errors[:item][:category][:name])
    end

    test "update_stock/2 with valid new data updates the stock" do
      current_stock = insert(:stock)
      attrs = deep_params_for_stock()

      assert {:ok, %Stock{} = stock} = Inventory.update_stock(current_stock, attrs)
      assert stock.count == attrs.count
      assert stock.description == attrs.description
      # TODO: test stock.photo

      assert stock.project_id == attrs.project_id

      assert %Item{} = stock.item
      assert stock.item.name == attrs.item.name

      assert %Category{} = stock.item.category
      assert stock.item.category.name == attrs.item.category.name

      assert %Mod{} = stock.mod
      assert stock.mod.gender == attrs.mod.gender || (stock.mod.gender == nil && attrs.mod.gender == "")
      assert stock.mod.age == attrs.mod.age || (stock.mod.age == nil && attrs.mod.age == "")
      assert stock.mod.size == attrs.mod.size || (stock.mod.size == nil && attrs.mod.size == "")
      assert stock.mod.season == attrs.mod.season || (stock.mod.season == nil && attrs.mod.season == "")

      assert %Packaging{} = stock.packaging
      assert stock.packaging.count == attrs.packaging.count
      assert stock.packaging.type == attrs.packaging.type
      assert stock.packaging.description == attrs.packaging.description
      # TODO: test stock.packaging.photo
    end

    test "update_stock/2 with valid existing data updates the stock" do
      current_stock = insert(:stock)
      attrs = deep_params_for_stock(%{
        project: insert(:project),
        item: insert(:item), # NOTE: a category is inserted by the item factory
        mod: build(:mod) # NOTE: mods already exist in the DB
      })

      assert {:ok, %Stock{} = stock} = Inventory.update_stock(current_stock, attrs)
      assert stock.count == attrs.count
      assert stock.description == attrs.description
      # TODO: test stock.photo

      assert stock.project_id == attrs.project_id

      assert %Item{} = stock.item
      assert stock.item.name == attrs.item.name

      assert %Category{} = stock.item.category
      assert stock.item.category.name == attrs.item.category.name

      assert %Mod{} = stock.mod
      assert stock.mod.gender == attrs.mod.gender || (stock.mod.gender == nil && attrs.mod.gender == "")
      assert stock.mod.age == attrs.mod.age || (stock.mod.age == nil && attrs.mod.age == "")
      assert stock.mod.size == attrs.mod.size || (stock.mod.size == nil && attrs.mod.size == "")
      assert stock.mod.season == attrs.mod.season || (stock.mod.season == nil && attrs.mod.season == "")

      assert %Packaging{} = stock.packaging
      assert stock.packaging.count == attrs.packaging.count
      assert stock.packaging.type == attrs.packaging.type
      assert stock.packaging.description == attrs.packaging.description
      # TODO: test stock.packaging.photo
    end

    test "update_stock/2 with invalid data returns error changeset" do
      # TODO: shouldn't be able to change project of a stock
      current_stock = insert(:stock)

      # is nil
      nil_attrs = deep_params_for_stock()
      nil_attrs = Map.put(nil_attrs, :project_id, nil)
      assert {:error, %Ecto.Changeset{} = changeset} = Inventory.update_stock(current_stock, nil_attrs)
      assert 1 == length(changeset.errors)

      # too short
      assoc_params = %{
        item: Map.put(params_for(:invalid_short_item), :category, params_for(:invalid_short_category)),
        mod: params_for(:mod),
        packaging: params_for(:invalid_short_packaging)
      }
      short_attrs = Enum.into(assoc_params, params_for(:invalid_short_stock))
      assert {:error, %Ecto.Changeset{} = changeset} = Inventory.update_stock(current_stock, short_attrs)
      errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, _} -> msg end)
      assert 1 == length(errors[:count])
      assert 1 == length(errors[:item][:name])
      assert 1 == length(errors[:item][:category][:name])
      assert 1 == length(errors[:packaging][:count])
      assert 1 == length(errors[:packaging][:type])

      # too long
      assoc_params = %{
        item: Map.put(params_for(:invalid_long_item), :category, params_for(:invalid_long_item)),
        mod: params_for(:mod),
        packaging: params_for(:packaging)
      }
      long_attrs = Enum.into(assoc_params, params_for(:stock))
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
