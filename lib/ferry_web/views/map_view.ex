defmodule FerryWeb.MapView do
  use FerryWeb, :view

  alias Ferry.Profiles.Group.Logo

  def has_addresses?(addresses) do
    length(addresses) > 0
  end

  def format_addresses_for_map(addresses) do
    addresses
    |> Enum.map(&format_address_for_map/1)
    |> Jason.encode!()
    |> raw()
  end

  defp format_address_for_map(address) do
    marker_img = cond do
      is_nil(address.project) -> Logo.url({address.group.logo, address.group}, :thumb)
      true -> Logo.url({address.project.group.logo, address.project.group}, :thumb)
    end

    %{
      lat: address.geocode.lat |> html_escape() |> safe_to_string(),
      lng: address.geocode.lng |> html_escape() |> safe_to_string(),
      marker_content: render_to_string(FerryWeb.ComponentView, "address.partial.html", %{address: address}),
      marker_img: marker_img
    }
  end

  def render("view-specific-styles.html", _assigns) do
    ~E"""
      <link rel="stylesheet"
        href="https://unpkg.com/leaflet@1.5.1/dist/leaflet.css"
        integrity="sha512-xwE/Az9zrjBIphAcBb3F6JVqxf46+CDLwfLMHloNu6KEQCAWi6HcDUbeOfBIptF7tcCzusKFjFw2yuvEpDL9wQ=="
        crossorigin=""
      />
    """
  end

  def render("view-specific-scripts.html", _assigns) do
    ~E"""
      <script src="https://unpkg.com/leaflet@1.5.1/dist/leaflet.js"
        integrity="sha512-GffPMF3RvMeYyc1LWMHtK8EbPv0iNZ8/oTtHPx9/cc2ILxQ+u905qIwdpULaqDkyBKgOaB57QTMg7ztg8Jm2Og=="
        crossorigin=""
      ></script>
    """
  end
end
