defmodule Ferry.Repo.Migrations.ReplaceRoleLabelWithCheckboxes do
  use Ecto.Migration

  def change do
    alter table(:shipments_groups_roles) do
      remove :label, :string
      add :is_organizer, :boolean, null: false, default: false
      add :is_funder, :boolean, null: false, default: false
      add :is_other, :boolean, null: false, default: false
    end
  end
end
