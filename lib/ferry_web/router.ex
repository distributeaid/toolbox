defmodule FerryWeb.Router do
  use FerryWeb, :router
  import Phoenix.LiveDashboard.Router
  # import FerryWeb.Plugs.PutUser
  require Logger

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(Plug.Parsers,
      parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
      pass: ["*/*"],
      json_decoder: Jason
    )

    plug(FerryWeb.Plugs.PutUser)

    # if Application.get_env(:ferry, :auth, "enable") == "enable" do
    #   plug(:put_user)
    # else
    #   Logger.warn("User authentication is disabled!")
    # end
  end

  scope "/" do
    forward("/health", HeartCheck.Plug, heartcheck: FerryWeb.HeartCheck)
  end

  scope "/api" do
    pipe_through([:api])

    if Application.get_env(:ferry, :graphiql, "enable") == "enable" do
      forward(
        "/graphiql",
        Absinthe.Plug.GraphiQL,
        schema: FerryApi.Schema
      )

      Logger.warn("GraphiQL development UI is enabled")
    end

    forward(
      "/",
      Absinthe.Plug,
      schema: FerryApi.Schema
    )
  end

  if Application.get_env(:ferry, :dashboard, "disable") do
    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: FerryWeb.Telemetry, ecto_repos: [Ferry.Repo]
    end

    Logger.warn("Phoenix Live Dashboard is enabled")
  end
end
