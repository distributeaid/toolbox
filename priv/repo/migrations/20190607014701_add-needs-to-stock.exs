defmodule Ferry.Repo.Migrations.AddNeedsToStock do
  use Ecto.Migration

  def up do
    alter table(:inventory_stocks) do
      modify :count, :integer, from: :integer, null: false, default: 0 # misspelled `null` in previous migration
      add :need, :integer, null: false, default: 0
      add :unit, :string, null: false, default: "items"
    end

    rename table(:inventory_stocks), :count, to: :have
  end

  def down do
    rename table(:inventory_stocks), :have, to: :count

    alter table(:inventory_stocks) do
      # don't undo the change to :count when it's reverted, since that was a fixed mis-spelling
      remove :need
      remove :unit
    end
  end
end
