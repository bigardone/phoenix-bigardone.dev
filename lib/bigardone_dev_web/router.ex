defmodule BigardoneDevWeb.Router do
  use BigardoneDevWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BigardoneDevWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BigardoneDevWeb do
    pipe_through :browser

    live "/", HomeLive
    live "/blog", BlogLive
    live "/blog/:year/:month/:day/:slug", PostLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", BigardoneDevWeb do
  #   pipe_through :api
  # end
end
