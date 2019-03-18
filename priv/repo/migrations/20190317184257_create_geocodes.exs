defmodule Ferry.Repo.Migrations.CreateGeocodes do
  use Ecto.Migration

  def change do
    create table(:geocodes) do
      add :lat, :string, null: false
      add :lng, :string, null: false
      add :data, :map, null: false

      add :address_id, references(:addresses, on_delete: :delete_all)

      timestamps()
    end

    create index(:geocodes, [:address_id])
  end
end
