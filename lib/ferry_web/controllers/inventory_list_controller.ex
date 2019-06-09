defmodule FerryWeb.InventoryListController do
  use FerryWeb, :controller

  alias Ferry.Inventory


  # Inventory Controller
  # ==============================================================================

  # Show
  # ------------------------------------------------------------

  def show(conn, %{"inventory_list_controls" => controls} = params) do
    list_type = case params["type"] do
      "needs" -> :needs
      "available" -> :available
      _ -> :available
    end

    %{
      control_data: control_data,
      controls: controls,
      results: results
    } = Inventory.get_inventory_list(list_type, controls)

    render(conn, "show.html", list_type: list_type, control_data: control_data, changeset: controls, results: results)
  end

  def show(conn, params) do
    show conn, Map.put(params, "inventory_list_controls", %{})
  end

end
