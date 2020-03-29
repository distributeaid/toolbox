defmodule Ferry.HealthCheckTest do
  use FerryWeb.ConnCase, async: true

  test "health check query", %{conn: conn} do
    query = """
    {
      healthCheck
    }
    """

    res =
      conn
      |> post("/api", %{query: query})
      |> json_response(200)

    assert res == %{"data" => %{"healthCheck" => "ok"}}
  end
end
