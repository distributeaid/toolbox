defmodule Ferry.Repo.Migrations.RemoveInventory do
  use Ecto.Migration

  def change do
    drop(constraint(:inventory_stocks, :inventory_stocks_mod_id_fkey))
    drop(constraint(:inventory_stocks, :inventory_stocks_item_id_fkey))
    drop(constraint(:inventory_stocks, :inventory_stocks_project_id_fkey))
    drop(constraint(:inventory_stocks, :inventory_stocks_packaging_id_fkey))
    drop(constraint(:inventory_items, :inventory_items_category_id_fkey))

    drop table(:inventory_mods)
    drop table(:inventory_items)
    drop table(:inventory_packaging)
    drop table(:inventory_stocks)
    drop table(:inventory_categories)
  end
end
