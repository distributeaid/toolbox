defmodule Ferry.Links.Link do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ferry.Profiles.{Group, Project}
  alias Ferry.CRM.Contact

  schema "links" do
    field :label, :string
    field :url, :string

    belongs_to :group, Group # on_delete set in database via migration
    belongs_to :project, Project # on_delete set in database via migration
    belongs_to :contact, Contact # on_delete set in database via migration

    timestamps()
  end

  @doc false
  def changeset(link, attrs) do
    link
    |> cast(attrs, [:label, :url])
    |> validate_required([:url])
    |> validate_length(:label, max: 255)
    |> validate_format(:url, ~r/^https?:\/\/\S+[\.]\S{2,}$/)
    # TODO: add a changeset check constraint that matches the db one?
    #       https://hexdocs.pm/ecto/Ecto.Changeset.html#check_constraint/3
  end
end
