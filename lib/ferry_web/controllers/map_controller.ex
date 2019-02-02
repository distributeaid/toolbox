defmodule FerryWeb.MapController do
  use FerryWeb, :controller

  alias Ferry.Locations
  alias Ferry.Locations.Map

  def show(conn, map_params) do
    case Locations.get_map(map_params) do
      {:ok, %Map{} = map} ->
        render(conn, "show.html", map: map)
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "show.html", changeset: changeset)
    end
  end

end
