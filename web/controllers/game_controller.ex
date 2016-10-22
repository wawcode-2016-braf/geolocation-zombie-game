defmodule Zombie.GameController do

  use Zombie.Web, :controller

  def index(conn, _params) do
    render conn, "index.html", token: conn.assigns[:token], user: conn.assigns[:current_user]
  end
  
end