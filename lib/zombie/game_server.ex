defmodule Zombie.Game do
  @moduledoc """
  GenServer which deals with most of the game's logic
  """
  use GenServer
  require Logger

  alias Zombie.User

  @immune_time 120_000 #miliseconds
  @distance 50 # meters

  defmodule State do
    defstruct [:start_date, :players]
  end

  defmodule Player do
    defstruct [:user, :role]
  end

  def start_link(), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

	def init(_) do 
    Process.send_after(self, :start, 100)
		{:ok, %State{}}
	end

  def handle_info(:start, %State{} = state) do
    Logger.info "Game is starting"
    state = %State{state | players: [], start_date: DateTime.utc_now()}

    # TODO: Load state from database
    
		{:noreply, state}
	end
  def handle_info({:check_colisions, %User{} = user}, %State{} = state) do
    # TODO: Check if the user colides with any other user
    # Colisions count only if time passed from start is bigger than 

    {:noreply, state}
  end

  def handle_call({:join, %User{} = user}, _from, %State{players: players} = state) do

    players = 
      case Map.get(players, user.id) do
        nil -> 
          # TODO: Add Participation to database
          Map.put(players, %Player{user: user})
        p -> p
      end

    {:reply, state, %State{state | players: players}}
  end

  def user_join(%User{} = user) do
    GenServer.call(__MODULE__, {:join, user})
  end

  def user_move(%User{} = user, %{"latitude" => latitude, "longitude" => longitude}) do
    # TODO: Add location to database
    # TODO: Send notification to proper users about location change
    send(__MODULE__, {:check_colisions, user})
    :ok
  end

end