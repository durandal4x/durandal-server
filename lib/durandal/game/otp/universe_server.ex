defmodule Durandal.Game.UniverseServer do
  use GenServer
  use DurandalWeb, :server
  require Logger
  alias Durandal.Game.UniverseLib
  # alias Durandal.Engine

  @heartbeat_frequency_ms 1_000

  defmodule State do
    @moduledoc false
    defstruct ~w(universe_id universe next_tick topic tick_timer tick_in_progress? task_pid tick_count)a
  end

  @impl true
  # def handle_call(:get_lobby_state, _from, state) do
  #   {:reply, state.lobby, state}
  # end

  def handle_call(:tick_in_progress?, _from, %State{} = state) do
    {:reply, state.tick_in_progress?, state}
  end

  def handle_call(:tick_count, _from, %State{} = state) do
    {:reply, state.tick_count, state}
  end

  def handle_call(msg, _from, state) do
    raise "err: #{inspect(msg)}"
    {:reply, nil, state}
  end

  @impl true
  def handle_cast(:force_perform_tick, %State{} = state) do
    state
    |> perform_tick
    |> noreply
  end

  def handle_cast(msg, state) do
    raise "err: #{inspect(msg)}"

    state
    |> noreply
  end

  @impl true
  def handle_info(:heartbeat, %State{} = state) do
    state
    |> maybe_perform_tick
    |> noreply
  end

  # Standard task completion
  def handle_info({:DOWN, _ref, :process, _pid, :normal}, %State{} = state) do
    state
    |> noreply
  end

  def handle_info({:DOWN, _ref, :process, pid, _exception}, %State{} = state) do
    if pid == state.task_pid do
      state
      |> cancel_tick
    else
      state
    end
    |> noreply
  end

  def handle_info(%{topic: "Durandal.Game.Universe:" <> _} = msg, %State{} = state) do
    case msg.event do
      :updated_universe ->
        state
        |> struct(%{universe: msg.universe})
        |> maybe_perform_tick
        |> noreply

      :completed_tick ->
        state
        |> complete_tick
        |> noreply

      _ ->
        state
        |> noreply
    end
  end

  defp maybe_perform_tick(%{tick_in_progress?: true} = state), do: state

  defp maybe_perform_tick(state) do
    if state.universe.active? && state.universe.next_tick &&
         DateTime.compare(state.universe.next_tick, DateTime.utc_now()) == :lt do
      state
      |> perform_tick
    else
      state
    end
  end

  defp perform_tick(state) do
    task_supervisor = UniverseLib.task_supervisor_name(state.universe_id)
    server_pid = self()

    {:ok, task_pid} =
      Task.Supervisor.start_child(task_supervisor, fn ->
        Durandal.broadcast(state.topic, %{
          event: :started_tick,
          topic: state.topic,
          universe_id: state.universe_id,
          server_pid: server_pid,
          task_pid: self()
        })

        Durandal.Engine.TickTask.perform_tick(state.universe_id)

        Durandal.broadcast(state.topic, %{
          event: :completed_tick,
          topic: state.topic,
          universe_id: state.universe_id,
          server_pid: server_pid
        })
      end)

    Process.monitor(task_pid)

    state
    |> struct(%{tick_in_progress?: true, task_pid: task_pid})
  end

  # The tick never completed, we need to be able to start a new tick
  defp cancel_tick(state) do
    state
    |> struct(%{tick_in_progress?: false, task_pid: nil})
  end

  # The tick completed, bring on the next one!
  defp complete_tick(state) do
    # It's possible that the universe was updated during the tick and we've
    # not updated our cached version yet
    universe = UniverseLib.get_universe!(state.universe_id)
    {:ok, universe} = UniverseLib.update_universe(universe, %{last_tick: DateTime.utc_now()})

    Logger.info("Tick completed for #{state.universe_id}, next tick at #{universe.next_tick}")

    state
    |> struct(%{
      tick_in_progress?: false,
      task_pid: nil,
      universe: universe,
      tick_count: state.tick_count + 1
    })
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
      Durandal.UniverseServerRegistry,
      universe_id,
      universe_id
    )

    # Horde.Registry.register(
    #   UniverseLib.registry_name(universe_id),
    #   universe_id,
    #   universe_id
    # )

    topic = UniverseLib.topic(universe_id)
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
       universe: universe,
       next_tick: universe.next_tick,
       tick_timer: nil,
       tick_in_progress?: false,
       task_pid: nil,
       tick_count: 0,
       topic: topic
     }}
  end
end
