defmodule Ferry.Repo.Migrations.AddListEntriesModValuesTable do
  use Ecto.Migration

  def change do
    create table(:aid__list_entries__mod_values) do
      add :entry_id, references(:aid__list_entries, on_delete: :delete_all)
      add :mod_value_id, references(:aid__mod_values, on_delete: :nothing)
      timestamps()
    end

    create unique_index(:aid__list_entries__mod_values, [:entry_id, :mod_value_id],
             name: :distinct_mod_values_per_list_entry
           )
  end
end
