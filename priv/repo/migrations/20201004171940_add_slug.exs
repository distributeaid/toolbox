defmodule Ferry.Repo.Migrations.AddSlug do
  use Ecto.Migration

  def change do
    alter table("aid__items") do
      add :slug, :text
    end

    alter table("aid__mods") do
      add :slug, :text
    end

    create unique_index("aid__items", [:slug])
    create unique_index("aid__mods", [:slug])
  end
end
