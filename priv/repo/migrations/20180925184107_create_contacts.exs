defmodule Ferry.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts) do
      add :label, :string
      add :description, :text

      add :group_id, references(:groups, on_delete: :delete_all)
      add :project_id, references(:projects, on_delete: :delete_all)

      timestamps()
    end

    create index(:contacts, [:group_id])
    create index(:contacts, [:project_id])

    create constraint(:contacts, :has_exactly_one_owner,
             check:
               "(group_id IS NOT NULL AND project_id IS NULL) OR (group_id IS NULL AND project_id IS NOT NULL)"
           )
  end
end
