defmodule FerryApi.Schema.GroupType do
  use Absinthe.Schema.Notation

  enum :group_type do
    value :m4d_chapter, as: "M4D_CHAPTER"
  end

  object :group do
    field :id, non_null(:id)

    # provided directly by user. e.g. Upper Manhatten, Whatcom County
    # validated for uniqueness
    # for now, collisions resolved manually E.g. "Manhatten (MT)"
    # must be upper / lower / number / spaces
    field :name, non_null(:string)
    field :description, :string
    # field :logo, :file (?)

    # kebab case of the name
    # e.g. upper-manhatten, whatcom-county
    field :slug, non_null(:string)

    field :type, non_null(:group_type)
#    field :location, non_null(:location_type)

    field :donation_link, :string

#    TODO: add in a migration
#    field :social_media_links, :link_type

    field :slack_channel_name, non_null(:string)
    field :request_form, :string
    field :volunteer_form, :string
    field :donation_form, :string

    # field :users, list_of(:user), resolve: dataloader(Group)
  end
end
