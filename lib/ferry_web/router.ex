defmodule FerryWeb.Router do
  use FerryWeb, :router

  import FerryWeb.Plugs.PutUserId

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug Plug.Parsers,
      parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
      pass: ["*/*"],
      json_decoder: Jason

    plug :put_user_id
  end

  scope "/" do
    forward "/health", HeartCheck.Plug, heartcheck: FerryWeb.HeartCheck
  end

  scope "/api" do
    pipe_through [:api]

    if Mix.env == :dev do
      forward "/graphiql",
              Absinthe.Plug.GraphiQL,
              schema: FerryApi.Schema
    end

    forward "/",
            Absinthe.Plug,
            schema: FerryApi.Schema
  end
end
