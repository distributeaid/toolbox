defmodule Ferry.Shipments.Role do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ferry.Profiles.Group
  alias Ferry.Shipments.Shipment

  schema "shipments_groups_roles" do
    field :supplier?, :boolean, default: false, source: :is_supplier
    field :receiver?, :boolean, default: false, source: :is_receiver
    field :organizer?, :boolean, default: false, source: :is_organizer
    field :funder?, :boolean, default: false, source: :is_funder
    field :other?, :boolean, default: false, source: :is_other
    field :description, :string

    # on_delete set in database via migration
    belongs_to :group, Group
    # on_delete set in database via migration
    belongs_to :shipment, Shipment

    timestamps()
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [
      :supplier?,
      :receiver?,
      :organizer?,
      :funder?,
      :other?,
      :description,
      :group_id,
      :shipment_id
    ])
    |> validate_required([:supplier?, :receiver?, :organizer?, :funder?, :other?, :group_id])
    # TODO: :shipment_id not validated to allow shipment creation to also create
    #       an initial role.  However this leaves direct role creation vulnerable
    #       to a missing :shipment_id.  Maybe make 2 changesets?  Or is validating
    #       the id's unnecessary since the assoc_constraints are there?

    |> validate_one_accepted([:supplier?, :receiver?, :organizer?, :funder?, :other?])
    |> assoc_constraint(:group)
    |> assoc_constraint(:shipment)
    |> unique_constraint(:group, name: :one_role_per_group_in_a_shipment)
  end

  @doc false
  defp validate_one_accepted(changeset, fields) do
    if Enum.any?(fields, &get_field(changeset, &1)) do
      changeset
    else
      add_error(changeset, :role, "You must choose at least one role option.")
    end
  end
end
