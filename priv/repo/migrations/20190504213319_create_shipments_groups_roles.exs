defmodule Ferry.Repo.Migrations.CreateShipmentsGroupsRoles do
  use Ecto.Migration

  # NOTE: need to specify up / down functions instead of just a change function,
  #       since removing columns isn't reversible by default.

  def up do
    create table(:shipments_groups_roles) do
      add :label, :string
      add :description, :text

      add :group_id, references(:groups, on_delete: :delete_all)
      add :shipment_id, references(:shipments, on_delete: :delete_all)

      timestamps()
    end

    create index(:shipments_groups_roles, [:group_id])
    create index(:shipments_groups_roles, [:shipment_id])

    create unique_index(:shipments_groups_roles, [:group_id, :shipment_id],
             name: :one_role_per_group_in_a_shipment
           )

    alter table(:shipments) do
      remove :group_id
      remove :receiver_group_id
    end
  end

  def down do
    drop table(:shipments_groups_roles)

    alter table(:shipments) do
      add :group_id, :integer
      add :receiver_group_id, :string
    end
  end
end
