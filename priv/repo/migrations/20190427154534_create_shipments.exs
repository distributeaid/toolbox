defmodule Ferry.Repo.Migrations.CreateShipments do
  use Ecto.Migration

  def change do
    create table(:shipments) do
      add :label, :string,  null: false
      add :target_date_to_be_shipped, :string
      add :status, :string
      add :group_id, :integer
      add :sender_address, :string
      add :items, :string
      add :funding, :string
      add :receiver_address, :string
      add :receiver_group_id, :string
      timestamps()
    end
  end
end