defmodule :"Elixir.Ferry.Repo.Migrations.Group-logos" do
  use Ecto.Migration

  def change do
    alter table(:groups) do
      add :logo, :string
    end
  end
end
