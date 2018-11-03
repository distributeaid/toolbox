defmodule FerryWeb.HomePageControllerTest do
  use FerryWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Distribute Aid"
  end
end
