defmodule Ferry.Repo.Migrations.AddGroupIdToAddresses do
  use Ecto.Migration

  def change do
    alter table(:addresses) do
      add :group_id, references(:groups, on_delete: :delete_all)
      add :project_id, references(:projects, on_delete: :delete_all)
    end

    create index(:addresses, [:group_id])
    create index(:addresses, [:project_id])

    create constraint(:addresses, :has_exactly_one_owner, check: "(group_id IS NOT NULL AND project_id IS NULL) OR (group_id IS NULL AND project_id IS NOT NULL)")
  end
end
