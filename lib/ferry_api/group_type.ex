defmodule FerryApi.Schema.GroupType do
  use Absinthe.Schema.Notation
  alias FerryApi.Schema.Dataloader.Repo
  import AbsintheErrorPayload.Payload
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  enum :group_type do
    value(:m4d_chapter, as: "M4D_CHAPTER")
  end

  object :group do
    # Required Fields
    # ------------------------------------------------------------
    field :id, non_null(:id)

    # provided directly by user. e.g. Upper Manhatten, Whatcom County
    # validated for uniqueness
    # for now, collisions resolved manually E.g. "Manhatten (MT)"
    field :name, non_null(:string)

    # kebab case of the name
    # e.g. upper-manhatten, whatcom-county
    field :slug, non_null(:string)

    # currently a constant set by the backend: "M4D_CHAPTER"
    field :type, non_null(:group_type)

    # Optional Fields
    # ------------------------------------------------------------

    # TODO: field :logo, :file (?)
    field :leader, :string
    field :description, :string
    field :donation_link, :string
    field :slack_channel_name, :string

    # TODO: field :social_media_links, :link_type

    field :request_form, :string
    field :request_form_results, :string
    field :volunteer_form, :string
    field :volunteer_form_results, :string
    field :donation_form, :string
    field :donation_form_results, :string

    # TODO
    # field :roles
    field :projects, list_of(:project), resolve: dataloader(Repo)
    field :addresses, list_of(:address), resolve: dataloader(Repo)

    field :users, list_of(:user_group) do
      middleware(FerryApi.Middleware.RequireDaOrGroupMember)
      middleware(Absinthe.Middleware.MapGet, :users)
    end
  end

  payload_object(:group_payload, :group)
end
