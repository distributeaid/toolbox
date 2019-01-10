defmodule FerryWeb.AddressView do
  use FerryWeb, :view

  def has_addresses?(addresses) do
    length(addresses) > 0
  end

  def format_addresses_for_map(addresses) do
    addresses
      |> Enum.map(fn address -> %{
        geoencoding_uri: format_geoencoding_uri(address),
        marker_content: format_marker_content(address)
      } end)
      |> Poison.encode!()
      |> raw()
  end

  defp format_geoencoding_uri(address) do
    address_string = ""
      <> if address.street, do: "#{address.street}, ", else: ""
      <> "#{address.city}, "
      <> if address.state, do: "#{address.state}, ", else: ""
      <> if address.zip_code, do: "#{address.zip_code}, ", else: ""
      <> address.country

    params = %{
      q: address_string,
      format: "json",
      limit: 1,
      email: "tools@distributeaid.org"
    }

    "https://nominatim.openstreetmap.org/search"
      |> URI.parse()
      |> Map.put(:query, URI.encode_query(params))
      |> URI.to_string()
  end

  defp format_marker_content(address) do
    render(FerryWeb.ComponentView, "address.partial.html", %{address: address})
      |> raw()
      |> safe_to_string()
  end

  # TODO: this limits loading the styles to Address views, but it still loads
  #       them on all Address views (including edit, etc)
  def render("view-specific-styles.html", _assigns) do
    ~E"""
      <link rel="stylesheet"
        href="https://unpkg.com/leaflet@1.4.0/dist/leaflet.css"
        integrity="sha512-puBpdR0798OZvTTbP4A8Ix/l+A4dHDD0DGqYW6RQ+9jxkRFclaxxQb/SJAWZfWAkuyeQUytO7+7N4QKrDh+drA=="
        crossorigin=""
      />
    """
  end

  # TODO: this limits loading the scripts to Address views, but it still loads
  #       them on all Address views (including edit, etc)
  def render("view-specific-scripts.html", _assigns) do
    ~E"""
      <script src="https://unpkg.com/leaflet@1.4.0/dist/leaflet.js"
        integrity="sha512-QVftwZFqvtRNi0ZyCtsznlKSWOStnDORoefr1enyq5mVL4tmKB3S/EnC3rRJcxCPavG10IcrVGSmPh6Qw5lwrg=="
        crossorigin=""
      ></script>
    """
  end
end
