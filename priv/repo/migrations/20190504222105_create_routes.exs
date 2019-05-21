defmodule Ferry.Repo.Migrations.CreateRoutes do
  use Ecto.Migration

  def change do
    create table(:routes) do
      add :label, :string
      add :address, :string
      add :date, :string
      add :groups, :string
      add :checklist, {:array, :string}

      add :shipment_id, references(:shipments, on_delete: :delete_all), null: false

      timestamps()
    end

  end
end
