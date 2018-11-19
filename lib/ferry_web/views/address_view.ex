defmodule FerryWeb.AddressView do
  use FerryWeb, :view

  def has_addresses?(addresses) do
    length(addresses) > 0
  end
end
