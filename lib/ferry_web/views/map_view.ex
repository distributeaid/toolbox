defmodule FerryWeb.MapView do
  use FerryWeb, :view

  def has_addresses?(addresses) do
    length(addresses) > 0
  end

  def format_addresses_for_map(addresses) do
    addresses
    |> Enum.map(fn address -> %{
        lat: address.geocode.lat |> html_escape() |> safe_to_string(),
        lng: address.geocode.lng |> html_escape() |> safe_to_string(),
        marker_content: render_to_string(FerryWeb.ComponentView, "address.partial.html", %{address: address})
    } end)
    |> Poison.encode!()
    |> raw()
  end

  def render("view-specific-styles.html", _assigns) do
    ~E"""
      <link rel="stylesheet"
        href="https://unpkg.com/leaflet@1.4.0/dist/leaflet.css"
        integrity="sha512-puBpdR0798OZvTTbP4A8Ix/l+A4dHDD0DGqYW6RQ+9jxkRFclaxxQb/SJAWZfWAkuyeQUytO7+7N4QKrDh+drA=="
        crossorigin=""
      />
    """
  end

  def render("view-specific-scripts.html", _assigns) do
    ~E"""
      <script src="https://unpkg.com/leaflet@1.4.0/dist/leaflet.js"
        integrity="sha512-QVftwZFqvtRNi0ZyCtsznlKSWOStnDORoefr1enyq5mVL4tmKB3S/EnC3rRJcxCPavG10IcrVGSmPh6Qw5lwrg=="
        crossorigin=""
      ></script>
    """
  end
end
