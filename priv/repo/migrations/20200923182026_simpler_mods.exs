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

    execute "ALTER TABLE aid__items__mods DROP CONSTRAINT aid__items__mods_mod_id_fkey"

    alter table(:aid__items__mods) do
      add :inserted_at, :timestamp, null: false
      add :updated_at, :timestamp, null: false
      modify :mod_id, references("aid__mods", on_delete: :nothing)
    end

    create unique_index(:aid__mod_values, [:mod_id, :value])
  end
end
