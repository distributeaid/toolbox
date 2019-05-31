defmodule :"Elixir.Ferry.Repo.Migrations.Add-index-to-routes" do
  use Ecto.Migration

  def change do
    create index(:routes, [:shipment_id])
  end
end
