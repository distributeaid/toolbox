defmodule Ferry.Repo.Migrations.DropLinkCategory do
  use Ecto.Migration

  def change do
    alter table(:links) do
      remove :category
    end
  end
end
