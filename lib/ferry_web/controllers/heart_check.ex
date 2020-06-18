# see https://github.com/locaweb/heartcheck-elixir#usage on defined more checks
defmodule FerryWeb.HeartCheck do
  use HeartCheck

  add :db_access do
    try do
      Ecto.Adapters.SQL.query(Ferry.Repo, "select 1", [])
      :ok
    rescue
      DBConnection.ConnectionError -> :error
    end
  end
end
