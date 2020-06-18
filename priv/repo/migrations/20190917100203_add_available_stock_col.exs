defmodule Ferry.Repo.Migrations.AddAvailableStockCol do
  use Ecto.Migration

  def up do
    alter table(:inventory_stocks) do
      add :available, :integer, null: false, default: 0
    end
  end

  def down do
    alter table(:inventory_stocks) do
      remove :available
    end
  end
end
