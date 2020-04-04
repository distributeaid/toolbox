defmodule Ferry.Profiles.Group do
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  alias Ferry.Accounts.User
  alias Ferry.Profiles.Group.Logo
  alias Ferry.Profiles.Project


  @group_types ["M4D_CHAPTER"]

  schema "groups" do
    field :name, :string
    field :description, :string
    field :logo, Logo.Type
    field :slug, :string
    field :type, :string

    field :donation_link, :string
    # TODO: social media links

    field :slack_channel_name, :string
    field :request_form, :string
    field :volunteer_form, :string
    field :donation_form, :string

    has_one :users, User # on_delete set in database via migration
    has_many :projects, Project # on_delete set in database via migration

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :description, :type, :donation_link, :slack_channel_name, :request_form, :volunteer_form, :donation_form])

    |> validate_required([:name, :type, :slack_channel_name])
    |> validate_length(:name, min: 1, max: 255)
    |> validate_format(:name, ~r/[A-Za-z0-9\ ]+/)
    |> unique_constraint(:name)

    |> set_slug()

    |> validate_inclusion(:type, @group_types)
  end

  @doc false
  def logo_changeset(group, attrs) do
    group
    |> cast_attachments(attrs, [:logo])
  end

  def set_slug(changeset) do
    slug = fetch_field!(changeset, :name)
    |> String.downcase()
    |> String.replace(" ", "-")

    put_changeset(changeset, :slug, slug)
  end
end
