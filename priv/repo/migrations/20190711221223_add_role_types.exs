defmodule Ferry.Repo.Migrations.AddRoleTypes do
  use Ecto.Migration

  def change do
    alter table(:shipments_groups_roles) do
      add :is_supplier, :boolean, null: false, default: false
      add :is_receiver, :boolean, null: false, default: false
    end
  end
end
