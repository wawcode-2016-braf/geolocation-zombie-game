defmodule Zombie.GameController do

  use Zombie.Web, :controller

  alias Zombie.GameServer

  def index(conn, _params) do
    GameServer.user_join(conn.assigns[:current_user])
    player = GameServer.player_info(conn.assigns[:current_user])
    render conn, "index.html", token: conn.assigns[:token], user: conn.assigns[:current_user], zombie?: player.zombie?
  end
  
end