defmodule Ferry.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string, null: false
      add :description, :string
      add :group_id, references(:groups, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:projects, [:name])
    create index(:projects, [:group_id])
  end
end
