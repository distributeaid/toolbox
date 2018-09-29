defmodule Ferry.CRM.Contact do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ferry.Profiles.{Group, Project}


  schema "contacts" do
    field :label, :string
    field :description, :string

    belongs_to :group, Group # on_delete set in database via migration
    belongs_to :project, Project # on_delete set in database via migration

    timestamps()
  end

  @doc false
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:label, :description])
    |> validate_length(:label, max: 255)
    # TODO: add a changeset check constraint that matches the db one?
    #       https://hexdocs.pm/ecto/Ecto.Changeset.html#check_constraint/3
  end
end
