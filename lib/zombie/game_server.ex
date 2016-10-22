defmodule Zombie.GameServer do
  use GenServer

  defmodule State do
    defstruct [:start_date, :players]
  end

  def start_link(), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

	def init(_) do 
		{:ok, %State{}}
	end

end