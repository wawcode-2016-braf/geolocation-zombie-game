defmodule Zombie.Plugs.Auth do
  @moduledoc """
  Plug makes assign `:current_user` available to controllers based on token
  """

  import Plug.Conn
  import Phoenix.Controller

  alias Zombie.{User, Repo}

  @doc """
  Callback invoked by Plug on every request
  """
  def init(opts), do: opts

  @doc """
  Callback required by Plug that checks that the reqeust is authorized
  """
  def call(conn, _opts), do: authorize(conn)

  defp authorize(conn = %{params: %{"token" => token}}) do
    case Phoenix.Token.verify(Zombie.Endpoint, "user", token) do
      {:ok, user_id} -> 
        case Repo.get(User, user_id) do
          %User{} = user ->
            conn 
            |> assign(:current_user, user)
            |> assign(:token, token)
          _ -> unauthorized(conn)
        end
      _ -> unauthorized(conn)
    end
  end
  defp authorize(conn), do: unauthorized(conn)

  defp unauthorized(conn) do
    conn
    |> put_status(401)
    |> render(Zombie.ErrorView, "401.json")
    |> halt()
  end

end