defmodule Ferry.Repo.Migrations.RemoveEntryIdFromModValues do
  use Ecto.Migration

  def change do
    alter table(:aid__mod_values) do
      remove :entry_id
      modify :value, :string, null: false
      modify :mod_id, :integer, null: false
    end

    create unique_index(:aid__mod_values, [:mod_id, :value])
  end
end
