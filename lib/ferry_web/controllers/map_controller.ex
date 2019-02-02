defmodule FerryWeb.MapController do
  use FerryWeb, :controller

  alias Ferry.Locations
  alias Ferry.Locations.Map

  # Show
  # ----------------------------------------------------------
  def show(conn, %{"map" => map_params}) do
    case Locations.get_map(map_params) do
      {:ok, %Map{} = map} ->
        render(conn, "show.html", changeset: Locations.change_map(map), map: map)
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "show.html", changeset: changeset)
    end
  end

  def show(conn, _) do
    show conn, %{"map" => %{}}
  end


end
