defmodule DurandalWeb.Admin.Game.Universe.ShowLive do
  @moduledoc false
  use DurandalWeb, :live_view
  alias Durandal.{Game, Space, Player}
  alias Durandal.Game.UniverseLib

  @restart_wait_time_ms 100

  @impl true
  def mount(%{"universe_id" => universe_id}, _session, socket) when is_connected?(socket) do
    socket =
      socket
      |> assign(:site_menu_active, "game")
      |> assign(:universe_id, universe_id)
      |> get_universe()

    if socket.assigns.universe do
      :ok = Durandal.subscribe(Game.universe_topic(universe_id))

      {:ok, socket}
    else
      {:ok, redirect(socket, to: ~p"/admin/games")}
    end
  end

  def mount(_params, _session, socket) do
    socket
    |> assign(:site_menu_active, "game")
    |> assign(:universe_id, nil)
    |> assign(:universe, nil)
    |> stream(:teams, [])
    |> stream(:systems, [])
    |> assign(:client, nil)
    |> ok
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, _params) do
    socket
    |> assign(:edit_mode, true)
  end

  defp apply_action(socket, _, _params) do
    socket
    |> assign(:edit_mode, false)
  end

  @impl true
  def handle_event("delete", _params, socket) do
    Durandal.Game.DeleteUniverseTask.perform(socket.assigns.universe_id)

    socket
    |> redirect(to: ~p"/admin/universes")
    |> put_flash(:info, "Universe deleted")
    |> noreply
  end

  # Calls the relevant shutdown and then starts a loop to await the shutdown being complete
  def handle_event("restart", _params, socket) do
    {:ok, universe} = Durandal.Game.update_universe(socket.assigns.universe, %{active?: false})
    :timer.send_after(@restart_wait_time_ms, self(), :await_shutdown)

    socket
    |> assign(:universe, universe)
    |> assign(:supervisor_pid, nil)
    |> assign(:server_pid, nil)
    |> noreply
  end

  @impl true
  def handle_info(:await_shutdown, %{assigns: %{universe: universe}} = socket) do
    case UniverseLib.get_game_supervisor_pid(universe.id) do
      # No pid, it's shutdown
      nil ->
        {:ok, universe} = Durandal.Game.update_universe(universe, %{active?: true})

        socket
        |> assign(:universe, universe)

      # Not stopped yet, wait a bit longer
      _ ->
        :timer.send_after(@restart_wait_time_ms, self(), :await_shutdown)
        socket
    end
    |> noreply
  end

  # Universe updates
  def handle_info(
        %{event: :updated_universe, topic: "Durandal.Game.Universe:" <> _} = msg,
        socket
      ) do
    socket
    |> assign(:universe, msg.universe)
    |> get_server_state
    |> noreply
  end

  def handle_info(
        %{event: :deleted_universe, topic: "Durandal.Game.Universe" <> _} = _msg,
        socket
      ) do
    socket
    |> redirect(to: ~p"/admin/universes")
    |> noreply
  end

  def handle_info(
        %{event: :started_tick, topic: "Durandal.Game.Universe:" <> _} = _msg,
        socket
      ) do
    socket
    |> assign(:tick_in_progress, true)
    |> noreply
  end

  def handle_info(
        %{event: :completed_tick, topic: "Durandal.Game.Universe:" <> _} = _msg,
        socket
      ) do
    socket
    |> assign(:tick_in_progress, false)
    |> noreply
  end

  # System updates
  def handle_info(%{event: :created_system, topic: "Durandal.Game.Universe:" <> _} = msg, socket) do
    socket
    |> stream_insert(:systems, msg.system)
    |> noreply
  end

  def handle_info(%{event: :updated_system, topic: "Durandal.Game.Universe:" <> _} = msg, socket) do
    socket
    |> stream_insert(:systems, msg.system)
    |> noreply
  end

  def handle_info(%{event: :deleted_system, topic: "Durandal.Game.Universe" <> _} = msg, socket) do
    socket
    |> stream_delete(:systems, msg.system)
    |> noreply
  end

  # Team updates
  def handle_info(%{event: :created_team, topic: "Durandal.Game.Universe:" <> _} = msg, socket) do
    socket
    |> stream_insert(:teams, msg.team)
    |> noreply
  end

  def handle_info(%{event: :updated_team, topic: "Durandal.Game.Universe:" <> _} = msg, socket) do
    socket
    |> stream_insert(:teams, msg.team)
    |> noreply
  end

  def handle_info(%{event: :deleted_team, topic: "Durandal.Game.Universe" <> _} = msg, socket) do
    socket
    |> stream_delete(:teams, msg.team)
    |> noreply
  end

  def handle_info(
        {DurandalWeb.Game.UniverseFormComponent, {:updated_changeset, %{changes: _changes}}},
        socket
      ) do
    {:noreply, socket}
  end

  @spec get_universe(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_universe(%{assigns: %{universe_id: universe_id}} = socket) do
    universe = Game.get_universe!(universe_id)

    teams = Player.list_teams(where: [universe_id: universe_id], order_by: ["Name (A-Z)"])
    systems = Space.list_systems(where: [universe_id: universe_id], order_by: ["Name (A-Z)"])

    socket
    |> assign(:universe, universe)
    |> stream(:teams, teams, reset: true)
    |> stream(:systems, systems, reset: true)
    |> get_server_state
  end

  defp get_server_state(%{assigns: %{universe_id: universe_id}} = socket) do
    :timer.sleep(50)
    p = UniverseLib.get_universe_server_pid(universe_id)

    universe_server_state =
      if p != nil && Process.alive?(p) do
        :sys.get_state(p, 100)
      end

    supervisor_pid = UniverseLib.get_game_supervisor_pid(universe_id)
    server_pid = supervisor_pid && UniverseLib.get_universe_server_pid(universe_id)

    socket
    |> assign(:universe_server_state, universe_server_state)
    |> assign(:supervisor_pid, supervisor_pid)
    |> assign(:server_pid, server_pid)
  end
end
