defmodule Ferry.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :password_hash, :text, null: false

      add :group_id, references(:groups, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:users, [:email])
    create index(:users, [:group_id])
  end
end
