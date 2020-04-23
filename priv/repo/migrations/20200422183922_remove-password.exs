defmodule :"Elixir.Ferry.Repo.Migrations.Remove-password" do
  use Ecto.Migration

  def up do
    # Assert user list is empty
    [] = Ferry.Accounts.list_users()

    alter table(:users) do
      remove(:password_hash)
      modify(:group_id, :integer, null: true)
    end
  end

  def down do
    alter table(:users) do
      add(:password_hash, :text, null: false)
      modify(:group_id, :integer, null: false)
    end
  end
end
