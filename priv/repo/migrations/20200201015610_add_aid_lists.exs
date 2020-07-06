defmodule Ferry.Repo.Migrations.AddAidLists do
  use Ecto.Migration

  def change do
    # Item Category
    # ------------------------------------------------------------
    create table("aid__item_categories") do
      add :name, :text, null: false

      timestamps()
    end

    create unique_index("aid__item_categories", [:name])

    # Item
    # ------------------------------------------------------------
    create table("aid__items") do
      add :name, :text, null: false

      add :category_id, references("aid__item_categories", on_delete: :delete_all)

      timestamps()
    end

    create unique_index("aid__items", [:name])

    # List
    # ------------------------------------------------------------
    create table("aid__lists") do
      timestamps()
    end

    # List Entry
    # ------------------------------------------------------------
    create table("aid__list_entries") do
      add :amount, :integer, null: false

      add :list_id, references("aid__lists", on_delete: :delete_all)

      # Deleting an item will fail if it's referenced by a list entry.
      add :item_id, references("aid__items", on_delete: :nothing)

      timestamps()
    end

    # Mod
    # ------------------------------------------------------------
    create table("aid__mods") do
      add :name, :text, null: false
      add :description, :text
      add :type, :text, null: false
      add :values, {:array, :string}

      timestamps()
    end

    create unique_index("aid__mods", [:name])

    # Provide support for the many_to_many association between items and mods.
    #
    # NOTE: Primary key & timestamps have been left in so we can refactor this
    #       into a join schema later on if necessary.
    #
    # NOTE: Event though :delete_all is set on both sides, removing an entry on
    #       one of the referenced tables will remove all related entries here
    #       but NOT remove any entries from the other referenced table. Which is
    #       what we want. See:
    #       https://hexdocs.pm/ecto/Ecto.Schema.html#many_to_many/3-removing-data
    create table("aid__items__mods") do
      add :item_id, references("aid__items", on_delete: :delete_all)
      add :mod_id, references("aid__mods", on_delete: :delete_all)
    end

    # We only want to associate an item and a mod 1 time.  See the description
    # for the `unique` option on many_to_many relationships:
    # https://hexdocs.pm/ecto/Ecto.Schema.html#many_to_many/3-options
    create unique_index("aid__items__mods", [:item_id, :mod_id])

    # Mod Value
    # ------------------------------------------------------------
    create table("aid__mod_values") do
      add :value, :map

      add :entry_id, references("aid__list_entries", on_delete: :delete_all)

      # Deleting a mod will fail if it's referenced by a mod value.
      add :mod_id, references("aid__mods", on_delete: :nothing)

      timestamps()
    end
  end
end
