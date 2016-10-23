defmodule Zombie.GameServer do
  @moduledoc """
  GenServer which deals with most of the game's logic
  """
  use GenServer
  require Logger

  alias Zombie.{User, Location, Repo, PlayerView}

  @immune_time 120 # seconds
  @distance 25 # meters
  @human_reveal_interval 60 # seconds 
  @zombies_ratio 5 # zombies per human

  defmodule State do
    defstruct [:start_date, :players, :last_visible]
  end

  defmodule Player do
    defstruct [:user, :zombie?, :position, :last_position]
  end

  def start_link(), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

	def init(_) do 
    Process.send_after(self, :start, 100)
		{:ok, %State{}}
	end

  def handle_info(:start, %State{} = state) do
    Logger.info "Game is starting"
    state = %State{state | players: %{}, start_date: DateTime.utc_now(), last_visible: DateTime.utc_now()}

    # TODO: Load state from database

    Process.send_after(self, :loop, 2_000)
    
		{:noreply, state}
	end
  def handle_info(:loop, %State{players: players} = state) do
    Process.send_after(self, :loop, 4_000)

    state = 
      if (state.last_visible |> DateTime.to_unix) + @human_reveal_interval < (DateTime.utc_now() |> DateTime.to_unix) do
        Logger.info("#{inspect state}")
        # Send to all users information about humans

        humans =
          players
          |> Map.to_list
          |> Enum.filter_map(fn {_id, p} -> !p.zombie? end, fn {_id, p} -> %Player{p | last_position: p.position} end)

        Zombie.Endpoint.broadcast("room:lobby", "locations", 
          %{data: PlayerView.render("players.json", %{players: humans})})

        players = Map.merge(players, 
            humans
            |> Enum.map(fn h -> {h.user.id, h} end)
            |> Enum.into(%{})
          )
          
        %State{state | last_visible: DateTime.utc_now, players: players}
      else
        state
      end

    # Send to all users information about zombies constantly
    zombies =
      state.players
      |> Map.to_list
      |> Enum.filter_map(fn {_id, p} -> p.zombie? end, fn {_id, p} -> %Player{p | last_position: p.position} end)

    Zombie.Endpoint.broadcast("room:lobby", "locations", 
      %{data: PlayerView.render("players.json", %{players: zombies})})

    players = Map.merge(state.players, 
      zombies
      |> Enum.map(fn z -> {z.user.id, z} end)
      |> Enum.into(%{})
    )

    {:noreply, %State{state | players: players}}
  end
  def handle_info({:update_position, %User{} = user, longitude, latitude}, %State{players: players} = state) do
    # Save player's location
    players = Map.update!(players, user.id, fn player -> 
      %Player{player | position: {longitude, latitude}, 
      last_position: if player.zombie? do {longitude, latitude} else if player.last_position == nil do {longitude, latitude} else player.last_position end end} 
    end)

    changeset = Location.changeset(%Location{}, %{"lat" => Decimal.new(latitude), "lon" => longitude, "user_id" => user.id})
    Repo.insert!(changeset)

    {:noreply, %State{state | players: players}}
  end
  def handle_info({:check_colisions, %User{} = user}, %State{players: players} = state) do
    # TODO: Check if the user colides with any other user
    # Colisions count only if time passed from start is bigger than @immune_time

    IO.puts "=========CHECK COLLISIONS============="
    IO.puts "Game time elapsed #{(DateTime.utc_now |> DateTime.to_unix) - (state.start_date |> DateTime.to_unix)}s"

    if (DateTime.utc_now |> DateTime.to_unix) - (state.start_date |> DateTime.to_unix) > @immune_time do
      IO.puts "=========GAME READY============="

      player = Map.get(players, user.id)

      players
      |> Map.to_list
      |> Enum.each(fn {_id, p} -> 
        if player.user.id != p.user.id and player.zombie? != p.zombie? do
          if IO.inspect(Distance.GreatCircle.distance(player.position, p.position)) < @distance do
            Process.send_after(__MODULE__, {:new_game, if player.zombie? do player else p end}, 50)
          end
        end
      end)

      {:noreply, state}
    else
      {:noreply, state}
    end
  end
  def handle_info({:notify_user_move, user}, %State{players: players} = state) do
    player = Map.get(players, user.id)
    if (player.zombie?) do
      Zombie.Endpoint.broadcast("room:lobby", "location",
        %{data: PlayerView.render("player.json", %{player: player})})
    else
      players
      |> Map.to_list
      |> Enum.each(fn {_id, p} -> 
        if !p.zombie? do
          Zombie.Endpoint.broadcast("room:" <> p.user.name, "location", 
            %{data: PlayerView.render("player.json", %{player: player})})
        end
      end)
    end

    {:noreply, state}
  end
  def handle_info({:new_game, player}, %State{players: players} = state) do
    IO.puts "==========NEW GAME============="
    IO.puts "Winner: " <> player.user.name

    players
    |> Map.to_list
    |> Enum.each(fn {_id, p} -> 
        if player.user.id != p.user.id do
          Zombie.Endpoint.broadcast("room:" <> p.user.name, "gameover", %{})
        else
          Zombie.Endpoint.broadcast("room:" <> p.user.name, "win", %{})
        end
      end)

    # Hacky: Removing all users - we will refresh their webpages
    player = %Player{player | zombie?: false}
    {:noreply, %State{state | players: %{player.user.id => player}, start_date: DateTime.utc_now(), last_visible: DateTime.utc_now()}}
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
  def handle_call({:player_info, %User{} = user}, _from, %State{players: players} = state) do
    {:reply, Map.get(players, user.id), state}
  end
  def handle_call({:game_info, %User{} = user}, _from, %State{} = state) do

    player = Map.get(state.players, user.id)

    players = 
      if player.zombie? do
        state.players
        |> Map.to_list
        |> Enum.map(fn {_id, p} -> %{
          name: p.user.name,
          is_zombie: p.zombie?,
          position: p.last_position
        } end)
      else
        state.players
        |> Map.to_list
        |> Enum.map(fn {_id, p} -> %{
          name: p.user.name,
          is_zombie: p.zombie?,
          position: p.position
        } end)
      end

    info = %{
      players: players,
      start_date: state.start_date,
      last_visible: state.last_visible,
      next_visible: ((state.last_visible |> DateTime.to_unix) + @human_reveal_interval) |> DateTime.from_unix!
    }

    {:reply, info, state}
  end

  def user_join(%User{} = user) do
    GenServer.call(__MODULE__, {:join, user})
  end

  def user_leave(%User{} = user) do
    GenServer.call(__MODULE__, {:leave, user})
  end

  def user_move(%User{} = user, %{"longitude" => longitude, "latitude" => latitude}) do
    # Update user position in Game and database
    send(__MODULE__, {:update_position, user, longitude, latitude})
    # Send channel notification to proper users about location change
    send(__MODULE__, {:notify_user_move, user})
    # Check players colisions and report game result
    send(__MODULE__, {:check_colisions, user})
    :ok
  end

  def player_info(%User{} = user) do
    GenServer.call(__MODULE__, {:player_info, user})
  end

  def game_info(%User{} = user) do
    GenServer.call(__MODULE__, {:game_info, user})
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