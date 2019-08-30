defmodule Ferry.ManifestsTest do
  use Ferry.DataCase

  alias Ferry.Inventory
  alias Ferry.Inventory.Stock
  alias Ferry.Shipments
  alias Ferry.Shipments.Role
  alias Ferry.Shipments.Shipment
  alias Ferry.Manifests

  # Shipment Manifests
  # ==============================================================================

  setup do
    neither = insert(:group) |> with_project() |> with_project()
    supplier = insert(:group) |> with_project() |> with_project()
    receiver = insert(:group) |> with_project() |> with_project()
    both = insert(:group) |> with_project() |> with_project()

    shipment = insert(:shipment)
    _ = insert(:shipment_role, %{shipment: shipment, group: neither, supplier?: false, receiver?: false})
    _ = insert(:shipment_role, %{shipment: shipment, group: supplier, supplier?: true, receiver?: false})
    _ = insert(:shipment_role, %{shipment: shipment, group: receiver, supplier?: false, receiver?: true})
    _ = insert(:shipment_role, %{shipment: shipment, group: both, supplier?: true, receiver?: true})

    {:ok,
      shipment: shipment,
      groups: %{
        neither: neither,
        supplier: supplier,
        receiver: receiver,
        both: both
      }
    }
  end

  describe "manifests" do

    test "list_needs/1 returns all stock needed by receiving groups", %{shipment: shipment, groups: groups} do
      # no inventory
      assert Manifests.list_needs(shipment) == []

      # receiving groups only have stock with needs = 0
      _ = insert(:stock, %{project: groups.receiver.projects |> hd(), need: 0})
      assert Manifests.list_needs(shipment) == []

      # includes needs from all receiving groups
      need1 = insert(:stock, %{project: groups.receiver.projects |> hd(), need: 50})
      |> without_assoc([:project, :group, :projects], :many)
      |> without_assoc([:project, :address, :geocode])
      |> without_assoc([:packaging])

      need2 = insert(:stock, %{project: groups.both.projects |> hd(), need: 50})
      |> without_assoc([:project, :group, :projects], :many)
      |> without_assoc([:project, :address, :geocode])
      |> without_assoc([:packaging])

      assert Manifests.list_needs(shipment) == [need1, need2]

      # includes needs from all of a receiving group's projects
      need3 = insert(:stock, %{project: Enum.at(groups.receiver.projects, 1), need: 50})
      |> without_assoc([:project, :group, :projects], :many)
      |> without_assoc([:project, :address, :geocode])
      |> without_assoc([:packaging])

      assert Manifests.list_needs(shipment) == [need1, need2, need3]

      # doesn't include needs for non-receiving groups
      _ = insert(:stock, %{project: groups.neither.projects |> hd(), need: 50})
      assert Manifests.list_needs(shipment) == [need1, need2, need3]
    end

  end
end
