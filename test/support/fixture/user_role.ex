defmodule Ferry.Fixture.UserRole do
  @doc """
  A fixture that creates a user, and a membership
  for that user in that group, with the given role.

  The group lookup is by slug.

  The setup function is designed to work both in
  graphql tests and context tests. For graphql tests,
  we can optionally authenticate the user by 
  generating a new JWT token and placing it in the 
  connection.
  """
  alias Ferry.Profiles
  alias Ferry.Accounts
  import Plug.Conn

  def setup(context, data, opts \\ [])

  def setup(%{conn: conn} = context, data, opts) do
    {:ok, context} =
      context
      |> Map.drop([:conn])
      |> setup(data, opts)

    conn =
      case opts[:auth] do
        true ->
          # Generate a new JWT token, using the given user
          # email as claims, and put in the connection
          # so that it can be used in tests
          {:ok, token, _} = context.user |> Map.take([:email]) |> Ferry.Token.encode_token()

          conn
          |> put_req_header("authorization", "Bearer #{token}")

        _ ->
          conn
      end

    {:ok, Map.put(context, :conn, conn)}
  end

  def setup(context, %{group: group, user: email, role: role}, _opts) do
    {:ok, group} = Profiles.get_group_by_slug(group)
    {:ok, user} = Accounts.create_user(%{email: email})
    {:ok, user} = Accounts.set_user_role(user, group, role)

    {:ok, Map.merge(context, %{group: group, user: user})}
  end
end
