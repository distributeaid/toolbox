defmodule Ferry.Repo.Migrations.RemoveShipmentLabelCol do
  use Ecto.Migration

  def change do
    alter table(:shipments) do
      remove :label, :string, null: false
    end
  end
end
