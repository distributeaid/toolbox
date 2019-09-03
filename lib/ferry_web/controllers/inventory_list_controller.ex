defmodule FerryWeb.InventoryListController do
  use FerryWeb, :controller

  alias Ferry.Inventory
  alias Ferry.Profiles


  # Inventory Controller
  # ==============================================================================

  # Helpers
  # ------------------------------------------------------------

  # TODO: copied from group_controller, refactor into shared function or something
  defp current_group(_conn = %{assigns: %{current_user: %{group_id: group_id}}}) do
    Profiles.get_group!(group_id)
  end

  defp current_group(_conn) do
    nil
  end

  # Show
  # ------------------------------------------------------------
  def show(conn, _params) do
    inventory = Inventory.get_inventory()
    render(conn, "show.html", inventory: inventory, current_group: current_group(conn))
  end

end
