defmodule Ferry.Repo.Migrations.CreateRoutes do
  use Ecto.Migration

  def change do
    create table(:routes) do
      add :address, :string
      add :date, :string
      add :groups, :string

      timestamps()
    end

  end
end
