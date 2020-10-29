defmodule Ferry.Repo.Migrations.AddNormalizedName do
  use Ecto.Migration

  def change do
    alter table("groups") do
      add :normalized_name, :text, null: false
    end

    alter table("aid__item_categories") do
      add :normalized_name, :text, null: false
    end

    alter table("aid__items") do
      add :normalized_name, :text, null: false
    end
  end
end
