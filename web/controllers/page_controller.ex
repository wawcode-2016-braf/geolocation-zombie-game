defmodule Zombie.PageController do
  use Zombie.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
