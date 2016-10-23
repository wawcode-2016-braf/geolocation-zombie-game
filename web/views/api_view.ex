defmodule Zombie.ApiView do
  use Zombie.Web, :view

  def render("ok.json", _) do
    %{result: "ok"}
  end

  def render("info.json", %{info: info}) do
    %{info: %{
      players: render_many(info.players, Zombie.ApiView, "player.json"),
      start_date: info.start_date,
      last_visible: info.last_visible,
      next_visible: info.next_visible
    }}
  end

  def render("player.json", %{api: %{position: {lng, lat}} = player}) do
    %{
      name: player.name,
      is_zombie: player.is_zombie,
      position: %{
        lng: lng,
        lat: lat
      }
    }
  end
  def render("player.json", %{api: player}) do
    player
  end

end
