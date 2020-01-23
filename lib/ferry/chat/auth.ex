defmodule Ferry.Chat.Auth do
  @moduledoc """
  The Chat auth context.
  """

  import Ecto.Query, warn: false

  alias Ferry.Repo
  alias Ferry.Accounts.User
  alias Ferry.Accounts

  def resource_from_claims(%{"sub" => id}) do
    # FIXME: Create JWT using the privateKey, publicKey, for subject: id and contexts: ['general', 'random']
    {:ok, id}
  end
end
