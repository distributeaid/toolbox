defmodule FerryWeb.Router do
  use FerryWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :setup_auth do
    plug Ferry.Auth.SetupPipeline
  end

  pipeline :ensure_auth do
    plug Ferry.Auth.EnsurePipeline
  end

  pipeline :authorization do
    plug Ferry.Auth.AuthorizePipeline
  end

  scope "/", FerryWeb do
    pipe_through [:browser, :setup_auth]

    get "/", HomePageController, :index
  end

  scope "/public", FerryWeb do
    pipe_through [:browser, :setup_auth]

    resources "/session", SessionController, only: [:new, :create, :delete], singleton: true

    resources "/groups", GroupController, only: [:index, :show] do
      resources "/addresses", AddressController, only: [:index]
      resources "/links", LinkController, only: [:index, :show]
      resources "/projects", ProjectController, only: [:index, :show]
      resources "/users", UserController, only: [:new, :create] # TODO: move into admin scope
    end

    # TODO
    # resources "/inventory", StockController, only: [:index, :show]
    resources "/map", MapController, only: [:show], singleton: true
    resources "/projects", ProjectController, only: [:index]
  end

  scope "/", FerryWeb do
    pipe_through [:browser, :setup_auth, :ensure_auth, :authorization]

    resources "/groups", GroupController, only: [:edit, :update, :delete] do
      resources "/addresses", AddressController, except: [:index, :show]
      resources "/links", LinkController, except: [:index, :show]
      resources "/projects", ProjectController, except: [:index, :show]
      resources "/stock", StockController
      resources "/users", UserController, only: [:edit, :update]
      resources "/shipments", ShipmentController do
        resources "/roles", RoleController
        resources "/routes", RouteController
      end
    end
  end

  # TODO: setup admin scope, add /groups/new and move /users/* into it
end
