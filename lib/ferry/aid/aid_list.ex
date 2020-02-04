defmodule Ferry.Aid.AidList do
  use Ecto.Schema
#  import Ecto.Changeset

  alias Ferry.Aid.ListEntry

  schema "aid__lists" do
    has_many :entries, ListEntry, foreign_key: :list_id

    timestamps()
  end
end
