defmodule Ferry.Aid.Manifest do
  use Ecto.Schema
#  import Ecto.Changeset

  alias Ferry.Aid.AidList

  schema "aid__manifest" do
    field :packaging, :string

    # TODO: move this module to Shipments and encapsulate the cross-context dependencies there?
    #       ie from => role, origin => a more detailed version of addresses w/ pickup times
    belongs_to :from, Ferry.Profiles.Group
    belongs_to :to, Ferry.Profiles.Group
    belongs_to :origin, Ferry.Locations.Address
    belongs_to :destination, Ferry.Locations.Address
    belongs_to :list, AidList, foreign_key: :list_id

    # shortcut / enables polymorphic lists
    has_many :entries, through: [:list, :entries]

    timestamps()
  end
end
