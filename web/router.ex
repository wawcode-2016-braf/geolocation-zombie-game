defmodule Zombie.Router do
  use Zombie.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser_auth do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Zombie.Plugs.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug :accepts, ["json"]
    plug Zombie.Plugs.Auth
  end

  scope "/", Zombie do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/", Zombie do
    pipe_through :browser_auth

    get "/game", GameController, :index
  end

  scope "/api", Zombie do
    pipe_through :api

    get "/token/:name", TokenController, :token
  end

  scope "/api", Zombie do
    pipe_through :api_auth

    resources "/users", UserController, except: [:new, :edit]
    put "/location", LocationController, :save
  end
end
