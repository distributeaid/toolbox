defmodule Ferry.Repo.Migrations.CreateInventoryStocks do
  use Ecto.Migration

  def change do
    # Categories
    # ------------------------------------------------------------
    create table(:inventory_categories) do
      add :name, :string, null: false

      timestamps()
    end

    create unique_index(:inventory_categories, [:name])

    # Items
    # ------------------------------------------------------------
    create table(:inventory_items) do
      add :name, :string, null: false

      add :category_id, references(:inventory_categories), null: false

      timestamps()
    end

    create unique_index(:inventory_items, [:name])
    create index(:inventory_items, [:category_id])

    # Mods
    # ------------------------------------------------------------
    create table(:inventory_mods) do
      # ex: masc, fem
      add :gender, :string
      # ex: adult, child
      add :age, :string
      # ex: small, medium, large, x-large
      add :size, :string
      # ex: summer, winter
      add :season, :string

      timestamps()
    end

    # TODO: create unique index for the combo of all fields

    # Packaging
    # ------------------------------------------------------------
    create table(:inventory_packaging) do
      add :count, :integer, null: false
      add :type, :string, null: false
      add :description, :text
      add :photo, :string

      timestamps()
    end

    # Stocks
    # ------------------------------------------------------------
    create table(:inventory_stocks) do
      add :count, :integer, null: false
      add :description, :text
      add :photo, :string

      add :project_id, references(:projects), null: false
      add :item_id, references(:inventory_items), null: false
      add :mod_id, references(:inventory_mods), null: false
      add :packaging_id, references(:inventory_packaging)

      timestamps()
    end

    create index(:inventory_stocks, [:project_id])
    create index(:inventory_stocks, [:item_id])
    create index(:inventory_stocks, [:mod_id])
    create index(:inventory_stocks, [:packaging_id])

    # Seed The DB
    # ------------------------------------------------------------
    # NOTE: This is included in a transaction instead of the `/priv/repo/seeds.exs`
    #       file so that it is done in production.  We want the db to be seeded
    #       with this data as part of the usual migration process, and to
    #       prevent seeding it multiple times by accident which would produce
    #       duplicate entries.
    #
    # TODO
  end
end
