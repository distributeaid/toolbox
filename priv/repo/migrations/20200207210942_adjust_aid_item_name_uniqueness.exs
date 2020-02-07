defmodule Ferry.Repo.Migrations.AdjustAidItemNameUniqueness do
  use Ecto.Migration

  def change do
    drop index("aid__items", [:name])
    create unique_index("aid__items", [:category_id, :name])
  end
end
