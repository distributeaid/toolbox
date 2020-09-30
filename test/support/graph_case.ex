defmodule Ferry.ApiClient.GraphCase do
  import Phoenix.ConnTest
  @endpoint FerryWeb.Endpoint

  def graphql(conn, doc) do
    conn
    |> post("/api", %{query: doc})
    |> json_response(200)
  end
end
