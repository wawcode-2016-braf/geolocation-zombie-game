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

  pipeline :api_auth do
    plug :accepts, ["json"]
    plug Coherence.Authentication.Token, source: :params, param: "token"
  end

  scope "/", Zombie do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/game", GameController, :index
  end

  scope "/", Zombie do
    pipe_through :protected

  end

  scope "/api", Zombie do
    pipe_through :api

    get "/token/:name", TokenController, :token
  end

  scope "/api", Zombie do
    pipe_through :api_auth

    resources "/users", UserController, except: [:new, :edit]
  end
end
