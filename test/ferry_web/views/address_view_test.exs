defmodule FerryWeb.AddressViewTest do
  use FerryWeb.ConnCase, async: true

  alias FerryWeb.AddressView

  test "has_addresses/1 determines if there are addresses or not" do
    addresses = []
    refute AddressView.has_addresses? addresses

    # a pretend address...
    # since fixtures aren't setup in this testing file yet
    addresses = [%{label: "HQ", city: "København", country: "Denmark"}]
    assert AddressView.has_addresses? addresses
  end

end
