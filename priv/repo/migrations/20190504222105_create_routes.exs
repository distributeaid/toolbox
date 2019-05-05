defmodule Ferry.Repo.Migrations.CreateRoutes do
  use Ecto.Migration

  def change do
    create table(:routes) do
      add :label, :string
      add :address, :string
      add :date, :string
      add :groups, :string
      add :shipment_id, :string
      add :checklist, {:array, :string}

      timestamps()
    end

  end
end
