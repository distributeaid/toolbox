defmodule Ferry.Repo.Migrations.AddLeaderToGroups do
  use Ecto.Migration

  def change do
    alter table("groups") do
      add :leader, :text, null: false, default: ""
    end
  end
end
