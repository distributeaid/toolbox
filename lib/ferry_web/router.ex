defmodule FerryWeb.Router do
  use FerryWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FerryWeb do
    pipe_through :browser # Use the default browser stack

    get "/", HomePageController, :index

    resources "/groups", GroupController
      # TODO: move `/group/new` into an admin scope

    # TODO: see Nested Resources section of the guide to model relationships in the routes
    #       https://hexdocs.pm/phoenix/routing.html#nested-resources
  end

  # TODO: see Scoped Routes section of the guide to handle admin functionality
  #       https://hexdocs.pm/phoenix/routing.html#scoped-routes

  # Other scopes may use custom stacks.
  # scope "/api", FerryWeb do
  #   pipe_through :api
  # end
end
