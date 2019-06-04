defmodule Ferry.Shipments.Role do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ferry.Profiles.Group
  alias Ferry.Shipments.Shipment

  schema "shipments_groups_roles" do
    field :label, :string
    field :description, :string

    belongs_to :group, Group # on_delete set in database via migration
    belongs_to :shipment, Shipment # on_delete set in database via migration

    timestamps()
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:label, :description, :group_id, :shipment_id])
    |> validate_required([:label, :group_id])
    # TODO: :shipment_id not validated to allow shipment creation to also create
    #       an initial role.  However this leaves direct role creation vulnerable
    #       to a missing :shipment_id.  Maybe make 2 changesets?  Or is validating
    #       the id's unnecessary since the assoc_constraints are there?

    |> validate_length(:label, min: 1, max: 255)
    
    |> assoc_constraint(:group)
    |> assoc_constraint(:shipment)
    |> unique_constraint(:group, name: :one_role_per_group_in_a_shipment)
  end
end
