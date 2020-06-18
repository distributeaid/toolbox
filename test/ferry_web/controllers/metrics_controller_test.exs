defmodule FerryWeb.MetricsControllerTest do
  use FerryWeb.ConnCase

  test "GET /metrics", %{conn: conn} do
    conn = get(conn, "/metrics")
    assert text_response(conn, 200) =~ "erlang_vm_memory_bytes_total"
  end
end
