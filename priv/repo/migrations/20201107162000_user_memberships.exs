defmodule Ferry.Repo.Migrations.UserMemberships do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :group_id
      remove :cognito_id
    end
  end
end
