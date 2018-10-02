defmodule Ferry.Repo.Migrations.CreateEmails do
  use Ecto.Migration

  def change do
    create table(:emails) do
      add :email, :string

      add :contact_id, references(:contacts, on_delete: :delete_all)

      timestamps()
    end

    create index(:emails, [:contact_id])
  end
end
