defmodule FerryWeb.InventoryListController do
  use FerryWeb, :controller

  alias Ferry.Inventory


  # Inventory Controller
  # ==============================================================================

  # Show
  # ------------------------------------------------------------
  def show(conn, _params) do
    inventory = Inventory.get_inventory()
    render(conn, "show.html", inventory: inventory)
  end

end
