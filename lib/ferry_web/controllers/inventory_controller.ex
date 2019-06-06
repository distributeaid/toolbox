defmodule FerryWeb.InventoryController do
  use FerryWeb, :controller

  alias Ferry.Inventory
  alias Ferry.Inventory.InventoryListControls


  # Inventory Controller
  # ==============================================================================

  # Show
  # ------------------------------------------------------------

  def show(conn, %{"inventory_list_controls" => controls}) do
    %{
      control_data: control_data,
      controls: controls,
      results: results
    } = Inventory.get_inventory_list(controls)

    render(conn, "show.html", control_data: control_data, changeset: controls, results: results)
  end

  def show(conn, params) do
    show conn, Map.put(params, "inventory_list_controls", %{})
  end

end
