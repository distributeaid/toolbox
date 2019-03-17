defmodule Ferry.CRM.Contact do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ferry.Repo
  alias Ferry.Profiles.{Group, Project}
  alias Ferry.CRM.{Email, Phone}


  schema "contacts" do
    field :label, :string
    field :description, :string

    has_many :emails, Email, on_replace: :delete # on_delete set in database via migration
    has_many :phones, Phone, on_replace: :delete # on_delete set in database via migration

    belongs_to :group, Group # on_delete set in database via migration
    belongs_to :project, Project # on_delete set in database via migration

    timestamps()
  end

  @doc false
  def changeset(contact, attrs) do
    contact
    |> Repo.preload([:emails, :phones])
    |> cast(attrs, [:label, :description])
    |> cast_assoc(:emails)
    |> cast_assoc(:phones)
    |> validate_length(:label, max: 255)
    # TODO: add a changeset check constraint that matches the db one?
    #       https://hexdocs.pm/ecto/Ecto.Changeset.html#check_constraint/3
  end
end
