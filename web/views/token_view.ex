defmodule Zombie.TokenView do
  use Zombie.Web, :view

  def render("token.json", %{id: id, name: name, token: token, zombie?: zombie?}) do
    %{data: %{
      id: id,
      token: token,
      name: name,
      role: if zombie? do :zombie else :human end
    }}
  end

end
