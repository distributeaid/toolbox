defmodule Ferry.Aid.ManifestList do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ferry.Aid.AidList

  schema "aid__manifest_lists" do
    field :packaging, :string

    # TODO: verify that everything is in the same shipment (:shipment, :from, :to, :origin, :destination)
    #
    # TODO: verify?
    #         - from.supplier? == true
    #         - to.receiver? == true
    #         - origin.type == "pickup"
    #         - destination.type == "dropoff"

    belongs_to :shipment, Ferry.Shipments.Shipment

    belongs_to :from, Ferry.Shipments.Role, foreign_key: :from_role_id
    belongs_to :to, Ferry.Shipments.Role, foreign_key: :to_role_id

    belongs_to :origin, Ferry.Shipments.Route, foreign_key: :origin_route_id
    belongs_to :destination, Ferry.Shipments.Route, foreign_key: :destination_route_id

    has_one :list, AidList

    # shortcut / enables polymorphic lists
    has_many :entries, through: [:list, :entries]

    timestamps()
  end

  def create_changeset(manifest_list, params \\ %{}) do
    manifest_list
    |> cast(params, [:packaging, :from_role_id, :to_role_id, :origin_route_id, :destination_route_id])

    # NOTE: No assoc_constraints on :to or :destination, so that we can model
    #       an aid group on a shipment looking for someone to send aid to.
    |> assoc_constraint(:from)
    |> assoc_constraint(:origin)
  end

  # NOTE: :from_role_id isn't change-able but still required.  If the aid group
  #       contributing this portion of the shipment isn't doing it, or transfers
  #       the aid to another group, model that by moving the aid entries and
  #       then deleting this manifest.
  #
  #       :origin_route_id is change-able since the pickup stop may have changed.
  def update_changeset(manifest_list, params \\ %{}) do
    manifest_list
    |> cast(params, [:packaging, :origin_route_id, :to_role_id, :destination_route_id])

    |> assoc_constraint(:from)
    |> assoc_constraint(:origin)
  end

end
