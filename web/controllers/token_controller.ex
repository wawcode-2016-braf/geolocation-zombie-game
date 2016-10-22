defmodule Zombie.TokenController do
  use Zombie.Web, :controller

  alias Zombie.User

  def token(conn, %{"name" => name}) do

    user = 
      case Repo.get_by(User, %{name: name}) do
        nil -> 
          Zombie.User.changeset(%Zombie.User{}, %{name: name, email: name <> "@example.com", password: "secret", password_confirmation: "secret"})
          |> Zombie.Repo.insert!
        u -> u
      end

    token = Coherence.Authentication.Token.generate_token
    Coherence.CredentialStore.Agent.put_credentials(token, %{name: name, id: user.id})
    render(conn, "token.json", id: user.id, name: name, token: token)
  end
end
