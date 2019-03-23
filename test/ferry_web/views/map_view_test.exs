defmodule FerryWeb.MapViewTest do
  use FerryWeb.ConnCase, async: true

  alias FerryWeb.MapView

  test "has_addresses/1 determines if there are addresses or not" do
    addresses = []
    refute MapView.has_addresses? addresses

    # a pretend address...
    # since fixtures aren't setup in this testing file yet
    addresses = [%{label: "HQ", city: "København", country: "Denmark"}]
    assert MapView.has_addresses? addresses
  end

end
