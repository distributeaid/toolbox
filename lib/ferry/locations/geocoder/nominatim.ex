defmodule Ferry.Locations.Geocoder.Nominatim do
  @moduledoc """
    A Geocoder implementation for Nominatim.
  """

  # TODO: Make this into it's own worker? So failures don't interfere with the
  # web worker & we can better conform to the Nominatim usage policy of
  # 1 req / sec.
  #
  # Would also reduce the response time for a request that hits this call.
  # We could show a message "looking up the location, will appear on the map
  # soon".

  alias Ferry.Locations.Geocoder

  @behaviour Geocoder

  @impl Geocoder
  def geocode_address(address) do
    url = format_geocoding_url(address)
    headers = [
      {"Accept-Language", "en-US, en;q=0.5, *;q=0.1"},
      {"User-Agent", "DistributeAid/0.8 (https://distributeaid.org)"} # TODO: make into a config param
    ]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        handle_successful_geocoding_response(body)

      # unexpected response, like a 404
      {:ok, response} ->
        {:error, response}

      # request error, like no network connectivity
      {:error, error} ->
        {:error, error}
    end
  end

  defp format_geocoding_url(address) do
    params = %{
      email: "tools@distributeaid.org", # TODO: make into a config param
      format: "json",
      limit: 1,
      addressdetails: 1,

      street: address["street"],
      city: address["city"],
      state: address["province"],
      postalcode: address["postal_code"],
      country: address["country_code"]
    }

    "https://nominatim.openstreetmap.org/search"
      |> URI.parse()
      |> Map.put(:query, URI.encode_query(params))
      |> URI.to_string()
  end

  defp handle_successful_geocoding_response(body) do
    case Jason.decode(body) do
      {:ok, [%{} = geocode_data]} ->
        {:ok, %{
          lat: geocode_data["lat"],
          lng: geocode_data["lon"],
          data: geocode_data
        }}

      # no results found
      {:ok, []} ->
        {:error, %{msg: "geocode error: no results found", response_body: body}}


      # other data error
      {:ok, _} ->
        {:error, %{msg: "geocode error: unexpected data format", response_body: body}}

      # parse / decode error
      {:error, error} ->
        {:error, error}
    end
  end
end
