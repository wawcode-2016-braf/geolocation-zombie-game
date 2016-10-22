defmodule Zombie.Router do
  use Zombie.Web, :router
  use Coherence.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug Coherence.Authentication.Token, source: :params, param: "token"
  end

  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session, protected: true  # Add this
  end

  scope "/" do
    pipe_through :browser
    coherence_routes
  end

  scope "/" do
    pipe_through :protected
    coherence_routes :protected
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Zombie do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/", Zombie do
    pipe_through :protected

  end

  # Other scopes may use custom stacks.
  # scope "/api", Zombie do
  #   pipe_through :api
  # end
end
