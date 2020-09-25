defmodule Ferry.Repo.Migrations.SimplerMods do
  use Ecto.Migration

  def change do
    alter table(:aid__mod_values) do
      remove :entry_id
      modify :value, :string, null: false
      modify :mod_id, :integer, null: false
    end

    alter table(:aid__mods) do
      remove :values
    end

    alter table(:aid__items__mods) do
      add :inserted_at, :timestamp, null: false
      add :updated_at, :timestamp, null: false
    end

    create unique_index(:aid__mod_values, [:mod_id, :value])
  end
end
