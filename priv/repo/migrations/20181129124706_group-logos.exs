defmodule Ferry.Repo.Migrations.AddGroupLogos do
  use Ecto.Migration

  def change do
    alter table(:groups) do
      add :logo, :string
    end
  end
end
