defmodule Elixir.Ferry.Repo.Migrations.AddRouteOrdering do
  use Ecto.Migration

  def up do
    alter table(:routes) do
      remove :date
      add :date, :date
    end
  end

  def down do
    alter table(:routes) do
      modify :date, :string, from: :date
    end
  end
end
