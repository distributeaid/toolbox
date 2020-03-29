defmodule Ferry.Aid.AvailableList do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ferry.Aid.AidList

  schema "aid__available_lists" do
    belongs_to :at, Ferry.Locations.Address, foreign_key: :address_id

    has_one :list, AidList

    # shortcut / enforce that available lists belong to a project
    has_one :project, through: [:at, :project]

    # shortcut / enables polymorphic lists
    has_many :entries, through: [:list, :entries]

    timestamps()
  end

  def create_changeset(available_list, params \\ %{}) do
    available_list
    |> cast(params, [:address_id])
    |> assoc_constraint(:at)
  end

  # Doesn't make sense to update the list's location- instead some / all of the
  # items should be moved to another list.  This works even if there's a
  # warehouse move or something- just move all items to the AvailableList tied
  # to the new address (which models transferring them via van).
  #
  # def update_changeset(available_list, params \\ %{}) do
  #   available_list
  #   |> cast(params, [])
  # end
end
