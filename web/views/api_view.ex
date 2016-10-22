defmodule Zombie.ApiView do
  use Zombie.Web, :view

  def render("ok.json", _) do
    %{result: "ok"}
  end
end
