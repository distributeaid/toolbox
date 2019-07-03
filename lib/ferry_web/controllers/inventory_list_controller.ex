defmodule FerryWeb.InventoryListController do
  use FerryWeb, :controller

  alias Ferry.Inventory


  # Inventory Controller
  # ==============================================================================

  # Show
  # ------------------------------------------------------------

  # NOTE: Need to limit the string values of type since we are converting it to
  #       an atom.  For security and performance.
  #
  #       For performance see: https://hexdocs.pm/elixir/String.html#to_atom/1
  def show(conn, %{"type" => type} = params) when type in ["available", "needs"] do
    type = String.to_atom(type)
    inventory = Inventory.get_inventory(type)
    render(conn, "show.html", type: type, inventory: inventory)
  end

  def show(conn, params) do
    show(conn, Map.put(params, "type", "available"))
  end

end
