defmodule Ferry.Repo.Migrations.RemoveEntryIdFromModValues do
  use Ecto.Migration

  def change do
    alter table(:aid__mod_values) do
      remove :entry_id
      modify :value, :string
    end

    unique_index(:aid__mod_values, [:mod_id, :value])
  end
end
