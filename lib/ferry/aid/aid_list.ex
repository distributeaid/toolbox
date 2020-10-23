defmodule Ferry.Aid.AidList do
  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{}

  alias Ferry.Aid.Entry
  alias Ferry.Aid.AvailableList
  alias Ferry.Aid.NeedsList
  alias Ferry.Aid.ManifestList

  schema "aid__lists" do
    has_many :entries, Entry, foreign_key: :list_id

    # NOTE: Can only belong to 1 list implementation.  Enforced by a db check constraint.
    belongs_to :available_list, AvailableList
    belongs_to :needs_list, NeedsList
    belongs_to :manifest_list, ManifestList

    timestamps()
  end

  def create_changeset(aid_list, params \\ %{}) do
    # NOTE: use Ecto.build_assoc to set the correct list implementation field
    aid_list
    |> cast(params, [])
    |> check_constraint(:owner,
      name: :has_exactly_one_owner,
      message:
        "An aid list may only be associated with one list implementation (available / needs / manifest)."
    )
  end
end
