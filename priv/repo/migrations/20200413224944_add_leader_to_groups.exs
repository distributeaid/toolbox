defmodule Ferry.Repo.Migrations.AddLeaderToGroups do
  use Ecto.Migration

  def change do
    alter table("groups") do
      add :leader, :text, null: true
    end
  end
end
