defmodule Ferry.Repo.Migrations.AddIndexOnRoutes do
  use Ecto.Migration

  def change do
    create index(:routes, [:shipment_id])
  end
end
