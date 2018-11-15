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

  pipeline :auth do
    plug Ferry.Auth.AuthAccessPipeline
  end

  scope "/", FerryWeb do
    pipe_through :browser

    get "/", HomePageController, :index
  end

  scope "/public", FerryWeb do
    pipe_through :browser

    resources "/sessions", SessionController, only: [:new, :create, :delete]

    resources "/groups", GroupController, only: [:index, :show] do
      resources "/users", UserController, only: [:new, :create] # TODO: move into admin scope
      resources "/links", LinkController, only: [:index, :show]
      resources "/projects", ProjectController, only: [:index, :show]
    end

    resources "/projects", ProjectController, only: [:index]
  end

  scope "/", FerryWeb do
    pipe_through [:browser, :auth]

    resources "/groups", GroupController, except: [:new, :create] do
      resources "/links", LinkController
      resources "/projects", ProjectController
    end
  end

  # TODO: setup admin scope, add /groups/new and move /users/* into it

  # TODO: see Scoped Routes section of the guide to handle admin functionality
  #       https://hexdocs.pm/phoenix/routing.html#scoped-routes

  # Other scopes may use custom stacks.
  # scope "/api", FerryWeb do
  #   pipe_through :api
  # end
end
