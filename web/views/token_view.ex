defmodule Zombie.TokenView do
  use Zombie.Web, :view

  def render("token.json", %{id: id, name: name, token: token}) do
    %{data: %{
      id: id,
      token: token,
      name: name
    }}
  end

end
