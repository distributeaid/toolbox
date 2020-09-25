defmodule Ferry.FeatureCase do
  @spec __using__(Keyword.t()) :: any()
  defmacro __using__(tags) do
    file = tags[:file]

    quote do
      use Cabbage.Feature, file: unquote(file)
      import_feature(Ferry.GlobalFeatures)

      import Plug.Conn
      import Phoenix.ConnTest
      import Ferry.ApiClient.GraphCase
      alias FerryWeb.Router.Helpers, as: Routes

      import Ferry.Factory

      # The default endpoint for testing
      @endpoint FerryWeb.Endpoint

      setup do
        # Do something when the scenario is done
        on_exit(fn ->
          nil
        end)

        :ok = Ecto.Adapters.SQL.Sandbox.checkout(Ferry.Repo)
        Ecto.Adapters.SQL.Sandbox.mode(Ferry.Repo, {:shared, self()})

        conn =
          Phoenix.ConnTest.build_conn()
          |> Plug.Conn.put_req_header("authorization", "Bearer fake.token")

        %{conn: conn, token: nil, last: nil}
      end
    end
  end
end
