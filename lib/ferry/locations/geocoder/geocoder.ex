defmodule Ferry.Locations.Geocoder do
  @moduledoc """
    The Geocoder behaviour.
  """

  @type address() :: %{
          required(:city) => String.t(),
          required(:country) => String.t(),
          optional(:street) => String.t(),
          optional(:street) => String.t(),
          optional(:zip_code) => String.t()
        }

  @type geocode() :: %{
          lat: String.t(),
          lng: String.t(),
          data: any()
        }

  @callback geocode_address(address()) :: {:ok, geocode()} | {:error, any()}

  def geocode_address!(implementation, contents) do
    case implementation.geocode_address(contents) do
      {:ok, data} ->
        data

      {:error, error} ->
        raise ArgumentError, "geocoding error: #{error}"
        # TODO: is ArgumentError the right error to raise here?
    end
  end
end
