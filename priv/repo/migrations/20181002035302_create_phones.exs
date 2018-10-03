defmodule Ferry.Repo.Migrations.CreatePhones do
  use Ecto.Migration

  def change do
    create table(:phones) do
      add :country_code, :string
      add :number, :string

      add :contact_id, references(:contacts, on_delete: :delete_all)

      timestamps()
    end

    create index(:phones, [:contact_id])
  end
end
