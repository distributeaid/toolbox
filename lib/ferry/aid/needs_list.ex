defmodule Ferry.Aid.NeedsList do
  use Ecto.Schema
#  import Ecto.Changeset

  alias Ferry.Aid.AidList

  schema "aid__needs_list" do
    field :from, :date
    field :to, :date

    belongs_to :list, AidList, foreign_key: :list_id

    # shortcut / enables polymorphic lists
    has_many :entries, through: [:list, :entries]

    timestamps()
  end
end
