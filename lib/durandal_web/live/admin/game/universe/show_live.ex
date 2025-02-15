defmodule DurandalWeb.Admin.Game.Universe.ShowLive do
  @moduledoc false
  use DurandalWeb, :live_view
  alias Durandal.{Game, Space, Player}

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

  @impl true
  # Universe updates
  def handle_info(
        %{event: :updated_universe, topic: "Durandal.Game.Universe:" <> _} = msg,
        socket
      ) do
    socket
    |> assign(:universe, msg.universe)
    |> noreply
  end

  def handle_info(%{event: :deleted_universe, topic: "Durandal.Game.Universe" <> _} = msg, socket) do
    socket
    |> redirect(to: ~p"/admin/universes")
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
  end
end
