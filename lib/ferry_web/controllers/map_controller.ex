defmodule FerryWeb.MapController do
  use FerryWeb, :controller

  alias Ferry.Locations
  alias Ferry.Locations.Map, as: DAMap


  # Map Controller
  # ==============================================================================

  # Show
  # ----------------------------------------------------------

  def show(conn, %{"map" => map_params}) do
    case Locations.get_map(map_params) do
      {:ok, %DAMap{} = map} ->
        render(conn, "show.html", changeset: Locations.change_map(map), map: map)
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "show.html", changeset: changeset)
    end
  end

  def show(conn, params) do
    show conn, Map.put(params, "map", %{})
  end

end
