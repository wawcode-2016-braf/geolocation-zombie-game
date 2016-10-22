defmodule Zombie.LocationController do
  use Zombie.Web, :controller
  alias Zombie.GameServer

  def save(%{assigns: %{current_user: user}} = conn, %{"longitude" => _lon, "latitude" => _lat} = params) do
    GameServer.user_move(user, params)
    render conn, "ok.json"
  end
end