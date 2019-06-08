defmodule Ferry.Repo.Migrations.AddNeedsToStock do
  use Ecto.Migration

  def up do
    alter table(:inventory_stocks) do
      modify :count, :integer, from: :integer, null: false, default: 0 # misspelled `null` in previous migration
      add :needs, :integer, null: false, default: 0
      add :unit, :string, null: false, default: "items"
    end
  end

  def down do
    alter table(:inventory_stocks) do
      # don't actually want to reverse the change to :count since it was a correction
      remove :needs
      remove :unit
    end
  end
end

# TODO: only list available inventory on the homepage: stock - needs
# TODO: collapse mod'd entries into an unmodd'd total
