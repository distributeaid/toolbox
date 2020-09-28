defmodule Ferry.Repo.Migrations.SimplerShipments do
  use Ecto.Migration

  def change do
    alter table(:shipments) do
      remove :target_date
      remove :sender_address
      remove :receiver_address
      remove :transport_size
      add :available_from, :timestamp, null: false
      add :target_delivery, :timestamp, null: false
      add :pickup_address, :text, null: false
      add :delivery_address, :text, null: false
      add :transport_type, :string, null: false
    end
  end
end
