defmodule Ferry.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links) do
      add :category, :string
      add :label, :string
      add :url, :text, null: false

      add :group_id, references(:groups, on_delete: :delete_all)
      add :project_id, references(:projects, on_delete: :delete_all)
      add :contact_id, references(:contacts, on_delete: :delete_all)

      timestamps()
    end

    create index(:links, [:group_id])
    create index(:links, [:project_id])
    create index(:links, [:contact_id])

    create constraint(:links, :has_exactly_one_owner,
             check:
               "(group_id IS NOT NULL AND project_id IS NULL AND contact_id IS NULL) OR (group_id IS NULL AND project_id IS NOT NULL AND contact_id IS NULL) OR (group_id IS NULL AND project_id IS NULL AND contact_id IS NOT NULL)"
           )
  end
end
