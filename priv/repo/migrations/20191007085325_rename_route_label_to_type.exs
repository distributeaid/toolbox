defmodule Ferry.Repo.Migrations.RenameRouteLabelToType do
  use Ecto.Migration

  def change do
    rename table("routes"), :label, to: :type
  end
end
