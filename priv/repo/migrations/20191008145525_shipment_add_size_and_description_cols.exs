defmodule Ferry.Repo.Migrations.ShipmentAddSizeAndDescriptionCols do
  use Ecto.Migration

  def change do
    rename table(:shipments), :target_date_to_be_shipped, to: :target_date

    alter table(:shipments) do
      add :description, :text
      add :transport_size, :string
    end
  end
end
