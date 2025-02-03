defmodule Durandal.Game.UniverseServer do
  use GenServer
  use DurandalWeb, :server
  require Logger
  alias Durandal.Game.UniverseLib

  @heartbeat_frequency_ms 5_000

  defmodule State do
    @moduledoc false
    defstruct ~w(universe_id next_tick topic)a
  end

  @impl true
  # def handle_call(:get_lobby_state, _from, state) do
  #   {:reply, state.lobby, state}
  # end

  def handle_call(msg, _from, state) do
    raise "err: #{inspect(msg)}"
    {:reply, nil, state}
  end

  @impl true
  def handle_cast(msg, state) do
    raise "err: #{inspect(msg)}"

    state
    |> noreply
  end

  @impl true
  def handle_info(:heartbeat, %State{} = state) do
    state
    |> noreply
  end

  def handle_info(%{topic: "Durandal.Game.Universe:" <> _}, %State{} = state) do
    state
    |> noreply
  end

  @doc false
  @spec start_link(list) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  @impl true
  @spec init(map) :: {:ok, map}
  def init(%{universe_id: universe_id} = _args) do
    # Logger.metadata(request_id: "LobbyServer##{id}")
    :timer.send_interval(@heartbeat_frequency_ms, :heartbeat)

    # Update the queue pids cache to point to this process
    Horde.Registry.register(
      UniverseLib.registry_name(universe_id),
      universe_id,
      universe_id
    )

    topic = UniverseLib.universe_topic(universe_id)
    Durandal.subscribe(topic)

    # We send ourselves a message as if the universe was updated
    # so we only ever have to worry about it in one place
    universe = UniverseLib.get_universe!(universe_id)
    send(self(), %{
      event: :updated_universe,
      topic: topic,
      universe: universe,
      note: "self-sent message"
    })

    {:ok,
     %State{
        universe_id: universe_id,
        next_tick: universe.next_tick,
        topic: topic
     }}
  end
end
