defmodule Ferry.Repo.Migrations.CreateShipments do
  use Ecto.Migration

  def change do
    create table(:shipments) do
      add :sending_group_id, :integer, null: false
      add :sender_address, :string, null: false
      add :items, :string, null: false
      add :funding, :string, null: false
      add :reciever_address, :string, null: false
      add :reciever_group_id, :string, null: false
      timestamps()
    end

  end
end