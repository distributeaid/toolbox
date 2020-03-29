defmodule Ferry.Repo.Migrations.AddAidListImplementations do
  use Ecto.Migration

  def change do

    # Available List
    # ------------------------------------------------------------
    create table("aid__available_lists") do
      # Deleting an address (or a project) will fail if it has an available list.
      # Something has to happen to the aid during the project shutdown phase.
      # Was it given to another project? Trashed? Document that via the app.
      add :address_id, references("addresses", on_delete: :nothing), null: false

      timestamps()
    end
    
    # Needs List
    # ------------------------------------------------------------
    create table("aid__needs_lists") do
      add :from, :date, null: false
      add :to, :date, null: false

      # If a project is deleted it doesn't have any more needs, since they are
      # not real outside of the project's operations.
      add :project_id, references("projects", on_delete: :delete_all), null: false

      timestamps()
    end

    # Manifest List
    # ------------------------------------------------------------
    create table("aid__manifest_lists") do
      add :packaging, :text

      # Deleting the shipment, or a contributing role / route will fail if it.
      # The aid can't just disappear- it should probably be moved back into the
      # :from project's available inventory.
      add :shipment_id, references("shipments", on_delete: :nothing), null: false
      add :from_role_id, references("shipments_groups_roles", on_delete: :nothing), null: false
      add :origin_route_id, references("routes", on_delete: :nothing), null: false

      # Contrarily, deleting the receiving role / route is ok.  The aid can
      #  still be on the shipment, it just needs to go to another group or place.
      add :to_role_id, references("shipments_groups_roles", on_delete: :nilify_all)
      add :destination_route_id, references("routes", on_delete: :nilify_all)

      timestamps()
    end

    # Aid List
    # ------------------------------------------------------------
    alter table("aid__lists") do
      # Deleting any list implementation should delete the join table (and all
      # list entries / mod values...).  Enforce delete mechanics at the
      # list implementation level.
      add :available_list_id, references("aid__available_lists", on_delete: :delete_all)
      add :needs_list_id, references("aid__needs_lists", on_delete: :delete_all)
      add :manifest_list_id, references("aid__manifest_lists", on_delete: :delete_all)
    end

    create constraint("aid__lists", :has_exactly_one_owner, check: """
         (available_list_id IS NOT NULL AND needs_list_id IS NULL     AND manifest_list_id IS NULL    )
      OR (available_list_id IS NULL     AND needs_list_id IS NOT NULL AND manifest_list_id IS NULL    )
      OR (available_list_id IS NULL     AND needs_list_id IS NULL     AND manifest_list_id IS NOT NULL)
    """)

    # Mod Value
    # ------------------------------------------------------------
    # Each entry should only have 1 value for a related mod.
    create unique_index("aid__mod_values", [:entry_id, :mod_id])

  end
end
