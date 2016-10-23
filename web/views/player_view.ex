defmodule Zombie.PlayerView do
  use Zombie.Web, :view

  def render("players.json", %{players: players}) do
    render_many(players, Zombie.PlayerView, "player.json")
  end

  def render("player.json", %{player: %{last_position: {lng, lat}} = player}) do
    %{
      id: player.user.id,
      name: player.user.name,
      zombie: player.zombie?,
      lng: lng,
      lat: lat
    }
  end
  def render("player.json", %{player: player}) do
    %{
      id: player.user.id,
      name: player.user.name,
      zombie: player.zombie?,
      lng: nil,
      lat: nil
    }
  end

end
