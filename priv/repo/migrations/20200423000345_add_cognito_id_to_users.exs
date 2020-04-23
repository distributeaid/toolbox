defmodule Ferry.Repo.Migrations.AddCognitoIdToUsers do
  use Ecto.Migration

  def change do
    # Assert user list is empty
    [] = Ferry.Accounts.list_users()

    alter table(:users) do
      add(:cognito_id, :string, null: false)
    end

    create(index(:users, :cognito_id))
  end
end
