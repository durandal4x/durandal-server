defmodule Durandal.Game.WatcherServer do
  use GenServer
  use DurandalWeb, :server
  require Logger
  alias Durandal.Game.UniverseLib

  defmodule State do
    @moduledoc false
    defstruct ~w(topic)a
  end

  @impl true
  def handle_info(
        %{topic: "Durandal.Global.Universe", event: :created_universe} = msg,
        %State{} = state
      ) do
    # If we try to make it right away then it won't start up correctly
    # so we send it to ourselves in a second as if it was turned on
    if msg.universe.active? do
      :timer.send_after(1000, self(), %{
        topic: "Durandal.Global.Universe",
        event: :updated_universe,
        universe: msg.universe
      })
    end

    state
    |> noreply
  end

  def handle_info(
        %{topic: "Durandal.Global.Universe", event: :deleted_universe} = msg,
        %State{} = state
      ) do
    UniverseLib.stop_universe_supervisor(msg.universe.id)

    state
    |> noreply
  end

  def handle_info(
        %{topic: "Durandal.Global.Universe", event: :updated_universe} = msg,
        %State{} = state
      ) do
    case {msg.universe.active?, UniverseLib.get_game_supervisor_pid(msg.universe.id)} do
      {true, nil} ->
        UniverseLib.start_universe_supervisor(msg.universe.id)

      {false, pid} when is_pid(pid) ->
        UniverseLib.stop_universe_supervisor(msg.universe.id)

      _ ->
        :ok
    end

    state
    |> noreply
  end

  @doc false
  @spec start_link(any()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, [])
  end

  @impl true
  @spec init(map) :: {:ok, map}
  def init(_args) do
    # Logger.metadata(request_id: "LobbyServer##{id}")

    topic = UniverseLib.global_topic()
    Durandal.subscribe(topic)

    UniverseLib.list_universes(where: [active?: true], limit: :infinity, select: [:id])
    |> Enum.each(fn %{id: id} ->
      case UniverseLib.start_universe_supervisor(id) do
        {:ok, _pid} ->
          :ok

        {:error, {:already_started, _pid}} ->
          :ok

        v ->
          raise v
      end
    end)

    {:ok,
     %State{
       topic: topic
     }}
  end
end
