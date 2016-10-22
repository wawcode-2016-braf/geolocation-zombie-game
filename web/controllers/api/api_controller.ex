defmodule Zombie.ApiController do
  use Zombie.Web, :controller
  alias Zombie.GameServer

  def save_location(conn, %{"longitude" => lon, "latitude" => lat} = params) when is_binary(lon) do
    {lon, _} = Float.parse(lon)
    {lat, _} = Float.parse(lat)
    params = %{params | "longitude" => lon, "latitude" => lat}
    save_location(conn, params)
  end
  def save_location(%{assigns: %{current_user: user}} = conn, %{"longitude" => _lon, "latitude" => _lat} = params) do
    GameServer.user_move(user, params)
    render conn, "ok.json"
  end
end