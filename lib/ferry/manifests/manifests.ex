defmodule Ferry.Manifests do
  @moduledoc """
  The Manifests context.
  """

  import Ecto.Query, warn: false
  alias Ferry.Repo

  alias Ferry.Shipments.Role
  alias Ferry.Shipments.Shipment

  # Manifests
  # ==============================================================================

  def list_needs(%Shipment{} = shipment) do
    role_subquery = from r in Role,
      where: r.shipment_id == ^shipment.id

    query = from s in Stock,
      join: proj in assoc(s, :project),
      join: g in assoc(proj, :group),
      left_join: a in assoc(proj, :address),

      join: i in assoc(s, :item),
      join: c in assoc(i, :category),

      join: m in assoc(s, :mod),

      # This acts as part of our where clause: the subquery selects all roles in
      # the shipment.  By performing an inner-join on them through the group id
      # we are able to exclude all groups who don't have a role in the shipment.
      join: r in ^role_subquery,
      on: g.id == r.group_id,
      where: s.need > 0 and r.receiver? == true,

      order_by: s.id,

      preload: [
        project: {proj, group: g, address: a},
        item: {i, category: c},
        mod: m
      ]

    Repo.all(query)
  end

end
