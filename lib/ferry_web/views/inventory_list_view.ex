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

  def amount_header(:available) do
    "# Available"
  end

  def amount_header(:needs) do
    "# Needed"
  end

  def amount(:available, %Stock{have: have, need: need, unit: unit}) do
    ~s(#{have - need} #{unit})
  end

  def amount(:needs, %Stock{have: have, need: need, unit: unit}) do
    ~s(#{need - have} #{unit})
  end

  def render("header.partial.html", %{type: :available} = assigns) do
    ~E"""
      <header class="section__header">
        <h1 class="section__title">Available Items</h1>
        <h3>
          (<%= link "click here to see needed items", to: Routes.inventory_list_path(@conn, :show, type: "needs") %>)
        </h3>
      </header>
    """
  end

  def render("header.partial.html", %{type: :needs} = assigns) do
    ~E"""
      <header class="section__header">
        <h1 class="section__title">Needed Items</h1>
        <h3>
          (<%= link "click here to see available items", to: Routes.inventory_list_path(@conn, :show) %>)
        </h3>
      </header>
    """
  end

end
