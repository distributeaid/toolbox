defmodule Ferry.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :name, :string, null: false
      add :description, :text

      timestamps()
    end

    create unique_index(:groups, [:name])
  end
end
