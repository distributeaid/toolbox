defmodule FerryApi.Schema.GroupType do
  use Absinthe.Schema.Notation

  enum :group_type do
    value :m4d_chapter, as: "M4D_CHAPTER"
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

#    field :location, non_null(:location_type)

    # Optional Fields
    # ------------------------------------------------------------    

    # TODO: field :logo, :file (?)
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

    # Relations
    # ------------------------------------------------------------

    # TODO
    # field :users, list_of(:user), resolve: dataloader(Group)
    # field :roles
    # field :projects

  end
end
