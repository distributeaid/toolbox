defmodule Ferry.Repo.Migrations.CreateAddresses do
  use Ecto.Migration

  def change do
    create table(:addresses) do
      add :label, :string, null: false
      add :street, :string
      add :city, :string, null: false
      add :state, :string
      add :country, :string, null: false
      add :zip_code, :string

      timestamps()
    end

  end
end
