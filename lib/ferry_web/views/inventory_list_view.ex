defmodule FerryWeb.InventoryListView do
  use FerryWeb, :view

  alias Ferry.Inventory.Stock

  # copied from FerryWeb.StockView
  # TODO: refactor
  def print_gender(gender) do
    case gender do
      "masc" -> "male"
      "fem" -> "female"
      _ -> ""
    end
  end

end
