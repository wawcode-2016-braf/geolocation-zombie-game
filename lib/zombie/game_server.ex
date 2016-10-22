defmodule Zombie.GameServer do
  @moduledoc """
  GenServer which deals with most of the game's logic
  """
  use GenServer
  require Logger

  alias Zombie.User

  @immune_time 120_000 # miliseconds
  @distance 50 # meters
  @human_reveal_time 60 # seconds 
  @zombies_ratio 5 # zombies per human

  defmodule State do
    defstruct [:start_date, :players, :last_visible]
  end

  defmodule Player do
    defstruct [:user, :zombie?, :position]
  end

  def start_link(), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

	def init(_) do 
    Process.send_after(self, :start, 100)
		{:ok, %State{}}
	end

  def handle_info(:start, %State{} = state) do
    Logger.info "Game is starting"
    state = %State{state | players: %{}, start_date: DateTime.utc_now()}

    # TODO: Load state from database

    Process.send_after(self, :loop, 5_000)
    
		{:noreply, state}
	end
  def handle_info(:loop, %State{} = state) do
    Process.send_after(self, :loop, 10_000)

    IO.inspect state

    {:noreply, state}
  end
  def handle_info({:update_position, %User{} = user, longitude, latitude}, %State{players: players} = state) do
    # Save player's location
    players = Map.update!(players, user.id, fn player -> %Player{player | position: {longitude, latitude}} end)
    # TODO: Add location to database
    {:noreply, %State{state | players: players}}
  end
  def handle_info({:check_colisions, %User{} = user}, %State{} = state) do
    # TODO: Check if the user colides with any other user
    # Colisions count only if time passed from start is bigger than @immune_time

    {:noreply, state}
  end

  def handle_call({:join, %User{} = user}, _from, %State{players: players} = state) do

    {player, players} = Map.get_and_update(players, user.id, fn player -> 
        case player do
          nil -> 
            # TODO: Add Participation to database
            # Update player and get his value
            player = %Player{user: user, zombie?: !rand_human(players)}
            {player, player}
          p -> {p, p}
        end
      end)
    
    {:reply, {:ok, player.zombie?}, %State{state | players: players}}
  end
  def handle_call({:leave, %User{} = user}, _from, %State{players: players} = state) do
    players = 
      case Map.get(players, user.id) do
        nil -> players
        _p -> Map.delete(players, user.id)
      end

    {:reply, :ok, %State{state | players: players}}
  end

  def user_join(%User{} = user) do
    GenServer.call(__MODULE__, {:join, user})
  end

  def user_leave(%User{} = user) do
    GenServer.call(__MODULE__, {:leave, user})
  end

  def user_move(%User{} = user, %{"longitude" => longitude, "latitude" => latitude}) do
    send(__MODULE__, {:update_position, user, longitude, latitude})
    # TODO: Send channel notification to proper users about location change
    send(__MODULE__, {:check_colisions, user})
    :ok
  end

  # randomly give players role for being human or zombie
  defp rand_human(players) do
    zombies_count =
      players
      |> Map.values
      |> Enum.count(fn p -> p.zombie? end)

    players_count =
      players
      |> Map.values
      |> Enum.count(fn p -> !p.zombie? end)

    # k - ludzie
    # j - zombie
    # j/n - k + 1
    (zombies_count / @zombies_ratio - players_count + 1) * 10_000 > :rand.uniform(10_000)
  end

end