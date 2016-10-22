defmodule Zombie.Plugs.ApiAuth do
  @moduledoc """
  Plug makes assign `:token` available to controllers.
  """

  import Plug.Conn
  import Phoenix.Controller

  @doc """
  Callback invoked by Plug on every request
  """
  def init(opts), do: opts

  @doc """
  Callback required by Plug that checks that the reqeust is authorized
  """
  def call(conn, _opts), do: authorize(conn)

  defp authorize(conn = %{params: %{"token" => token}}) do
    user_id = Phoenix.Token.verify(Zombie.Endpoint, "user", token)

    if user_id == nil do
      unauthorized(conn)
    else
      conn
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