defmodule FerryWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      alias FerryWeb.Router.Helpers, as: Routes

      import Ferry.Factory

      # The default endpoint for testing
      @endpoint FerryWeb.Endpoint

      defp mock_sign_in(user) do
        Ferry.Mocks.AwsClient
        |> Mox.stub(:request, fn _args ->
          {:ok,
           %{
             "Username" => user.cognito_id,
             "UserAttributes" => [
               %{"Name" => "email_verified", "Value" => "true"},
               %{"Name" => "email", "Value" => user.email}
             ]
           }}
        end)

        user
      end
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Ferry.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Ferry.Repo, {:shared, self()})
    end

    conn =
      Phoenix.ConnTest.build_conn()
      |> Plug.Conn.put_req_header("authorization", "Bearer fake.token")

    Ferry.Mocks.AwsClient
    |> Mox.stub(:request, fn _ ->
      {:error,
       """
       You can explicitly change this mock in your test with
       Ferry.Mocks.AwsClient |> expect(...)
       """}
    end)

    {:ok, conn: conn}
  end
end
