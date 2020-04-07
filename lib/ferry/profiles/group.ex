defmodule Ferry.Profiles.Group do
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  alias Ferry.Accounts.User
  alias Ferry.Profiles.Group.Logo
  alias Ferry.Profiles.Project

  @group_types ["M4D_CHAPTER"]

  schema "groups" do
    # required
    field :name, :string
    field :slug, :string
    field :type, :string

    # profile
    field :logo, Logo.Type
    field :description, :string
    field :donation_link, Ferry.EctoType.URL
    field :slack_channel_name, :string
    # TODO: social media links

    # initial data entry
    # NOTE: will likely be removed soon (as each form is replaced by related functionality in the app)
    field :request_form, Ferry.EctoType.URL
    field :request_form_results, Ferry.EctoType.URL
    field :volunteer_form, Ferry.EctoType.URL
    field :volunteer_form_results, Ferry.EctoType.URL
    field :donation_form, Ferry.EctoType.URL
    field :donation_form_results, Ferry.EctoType.URL

    # relations
    has_one :users, User # on_delete set in database via migration
    has_many :projects, Project # on_delete set in database via migration

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [
      :name,

      :description,
      :donation_link,
      :slack_channel_name,

      :request_form,
      :request_form_results,
      :volunteer_form,
      :volunteer_form_results,
      :donation_form,
      :donation_form_results
    ])
    |> validate_required([
      :name
      # slug is generated from name
      # type is a constant for now
      # TODO: ^^^ that will likely change later
    ])

    |> validate_length(:name, min: 1, max: 255)
    |> validate_format(:name, ~r/[A-Za-z\ \-]+/)
    |> unique_constraint(:name)

    |> set_slug()
    |> unique_constraint(:slug)

    # Just set the type for now, while there's only one valid type.
    |> put_change(:type, "M4D_CHAPTER")
    |> validate_inclusion(:type, @group_types)
  end

  @doc false
  def logo_changeset(group, attrs) do
    group
    |> cast_attachments(attrs, [:logo])
  end

  # don't do anything if there are :name errors, b/c :slug is derived from :name
  defp set_slug(%{errors: [name: {_, _}]} = changeset) do
    changeset
  end

  defp set_slug(changeset) do
    slug = case fetch_field(changeset, :name) do
      # Bets on if Taylor's going to regret not handling this edge case better later on? ;)
      :error -> "we'll never get here cause we validate that :name exists already"
      {_source, nil} -> "we'll never get here cause we validate that :name exists already"

      # success case
      {_source, name} ->
        name
        |> String.downcase()
        |> String.trim()
        |> String.replace(~r/\s+/, "-")
    end

    put_change(changeset, :slug, slug)
  end
end
