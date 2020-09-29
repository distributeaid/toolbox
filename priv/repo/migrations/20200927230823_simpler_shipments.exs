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
      add :transport_type, :string, null: false
      add :pickup_address_id, references(:addresses, on_delete: :nothing, null: false)
      add :delivery_address_id, references(:addresses, on_delete: :nothing, null: false)
    end

    alter table(:addresses) do
      add :opening_hour, :string, null: false
      add :closing_hour, :string, null: false
      add :type, :string, null: false
      add :has_loading_equipment, :boolean
      add :has_unloading_equipment, :boolean
      add :needs_appointment, :boolean
    end
  end
end
