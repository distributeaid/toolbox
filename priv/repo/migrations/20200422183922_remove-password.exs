defmodule :"Elixir.Ferry.Repo.Migrations.Remove-password" do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove(:password_hash)
      modify(:group_id, :bigint, null: true)
    end
  end
end
