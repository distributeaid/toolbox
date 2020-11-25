defmodule Ferry.Repo.Migrations.AddUserGroups do
  use Ecto.Migration

  def change do
    create table(:user_groups) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :group_id, references(:groups)
      add :role, :text, null: false
      timestamps()
    end

    create unique_index(:user_groups, [:user_id, :group_id], name: :unique_role_per_user_per_group)
  end
end
