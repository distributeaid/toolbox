defmodule Ferry.Repo.Migrations.FixUniqueItemIndex do
  use Ecto.Migration

  def change do
    drop index(:inventory_items, [:name])
    create unique_index(:inventory_items, [:category_id, :name])
  end
end
