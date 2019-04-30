defmodule Ferry.Repo.Migrations.CreateShipments do
  use Ecto.Migration

  def change do
    create table(:shipments) do
      add :group_id, :integer
      add :sender_address, :string
      add :items, :string
      add :funding, :string
      add :reciever_address, :string
      add :reciever_group_id, :string
      timestamps()
    end
  end
end