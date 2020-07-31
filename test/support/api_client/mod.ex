defmodule Ferry.ApiClient.Mod do
  @moduledoc """
  Helper module that provides with a convenience GraphQL client api
  for dealing with Mods in tests.
  """

  import Ferry.ApiClient.Graphql

  @doc """
  Run a GraphQL query that counts mods
  """
  @spec count_mods(Plug.Conn.t()) :: map()
  def count_mods(conn) do
    graphql(conn, "{ countMods }")
  end
end
