defmodule FerryWeb.Router do
  use FerryWeb, :router
  import Redirect

  import FerryWeb.Plugs

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :setup_auth do
    plug Ferry.Auth.SetupPipeline
    plug :assign_current_group
  end

  pipeline :ensure_auth do
    plug Ferry.Auth.EnsurePipeline
  end

  pipeline :authorization do
    plug Ferry.Auth.AuthorizePipeline
  end

  pipeline :chat do
    plug :assign_chat_meta
  end

  pipeline :api do
    plug Plug.Parsers,
      parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
      pass: ["*/*"],
      json_decoder: Jason
  end

  scope "/" do
    pipe_through :browser

    forward "/health", HeartCheck.Plug, heartcheck: FerryWeb.HeartCheck
  end

  scope "/", FerryWeb do
    pipe_through [:browser, :setup_auth, :chat]

    get "/", HomePageController, :index
  end

  scope "/public", FerryWeb do
    pipe_through [:browser, :setup_auth, :chat]

    resources "/signup", UserController, only: [:new, :create], singleton: true
    resources "/session", SessionController, only: [:new, :create, :delete], singleton: true

    resources "/groups", GroupController, only: [:index, :show] do
      # TODO: move into admin scope
      resources "/users", UserController, only: [:new, :create]
    end

    resources "/inventory", InventoryListController, only: [:show], singleton: true
    resources "/map", MapController, only: [:show], singleton: true
    resources "/shipments", ShipmentOverviewController, only: [:index, :show]
  end

  scope "/", FerryWeb do
    pipe_through [:browser, :setup_auth, :ensure_auth, :authorization, :chat]

    resources "/groups", GroupController, only: [:edit, :update, :delete] do
      resources "/addresses", AddressController, except: [:index, :show]
      resources "/links", LinkController, except: [:show]
      resources "/projects", ProjectController, except: [:index, :show]
      resources "/inventory", StockController, except: [:show]
      resources "/users", UserController, only: [:edit, :update]

      resources "/shipments", ShipmentController do
        resources "/roles", RoleController, except: [:index, :show]
        resources "/routes", RouteController, except: [:index, :show]
      end
    end
  end

  # TODO: move "/public/groups/:group_id/users" to admin scope
  scope "/admin", FerryWeb do
    # TODO: restrict access to admin scope
    pipe_through [:browser, :setup_auth]

    # categories are visible / accessible via AidItemController:index
    resources "/aid/categories", AidCategoryController, except: [:index, :show]
    resources "/aid/items", AidItemController, except: [:show]
    resources "/aid/mods", AidModController, except: [:show]
  end

  redirect "/admin", "/admin/aid/items", :temporary
  redirect "/admin/aid", "/admin/aid/items", :temporary

  scope "/.well-known", FerryWeb do
    get "/jwks.json", JWKSController, :show, singleton: true
  end

  scope "/api" do
    pipe_through [:api]

    forward "/graphiql",
            Absinthe.Plug.GraphiQL,
            schema: Ferry.Schema

    forward "/",
            Absinthe.Plug,
            schema: Ferry.Schema
  end
end
