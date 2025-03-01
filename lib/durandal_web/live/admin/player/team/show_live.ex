defmodule DurandalWeb.Admin.Player.Team.ShowLive do
  @moduledoc false
  use DurandalWeb, :live_view
  alias Durandal.{Space, Player}

  @impl true
  def mount(%{"team_id" => team_id}, _session, socket) when is_connected?(socket) do
    socket =
      socket
      |> assign(:site_menu_active, "game")
      |> assign(:team_id, team_id)
      |> get_team()

    if socket.assigns.team do
      :ok = Durandal.subscribe(Player.team_topic(team_id))

      {:ok, socket}
    else
      {:ok, redirect(socket, to: ~p"/admin/games")}
    end
  end

  def mount(_params, _session, socket) do
    socket
    |> assign(:site_menu_active, "game")
    |> assign(:team_id, nil)
    |> assign(:team, nil)
    |> stream(:team_members, [])
    |> stream(:stations, [])
    |> stream(:ships, [])
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
    Durandal.Player.DeleteTeamTask.perform(socket.assigns.team_id)

    socket
    |> redirect(to: ~p"/admin/teams")
    |> put_flash(:info, "Team deleted")
    |> noreply
  end

  @impl true
  # Team updates
  def handle_info(%{event: :updated_team, topic: "Durandal.Player.Team:" <> _} = msg, socket) do
    socket
    |> assign(:team, msg.team)
    |> noreply
  end

  def handle_info(%{event: :deleted_team, topic: "Durandal.Player.Team" <> _} = _msg, socket) do
    socket
    |> redirect(to: ~p"/admin/teams")
    |> noreply
  end

  # Station updates
  def handle_info(%{event: :created_station, topic: "Durandal.Player.Team:" <> _} = msg, socket) do
    socket
    |> stream_insert(:stations, msg.station)
    |> noreply
  end

  def handle_info(%{event: :updated_station, topic: "Durandal.Player.Team:" <> _} = msg, socket) do
    socket
    |> stream_insert(:stations, msg.station)
    |> noreply
  end

  def handle_info(%{event: :deleted_station, topic: "Durandal.Player.Team" <> _} = msg, socket) do
    socket
    |> stream_delete(:stations, msg.station)
    |> noreply
  end

  # Ship updates
  def handle_info(%{event: :created_ship, topic: "Durandal.Player.Team:" <> _} = msg, socket) do
    socket
    |> stream_insert(:ships, msg.ship)
    |> noreply
  end

  def handle_info(%{event: :updated_ship, topic: "Durandal.Player.Team:" <> _} = msg, socket) do
    socket
    |> stream_insert(:ships, msg.ship)
    |> noreply
  end

  def handle_info(%{event: :deleted_ship, topic: "Durandal.Player.Team" <> _} = msg, socket) do
    socket
    |> stream_delete(:ships, msg.ship)
    |> noreply
  end

  def handle_info(
        {DurandalWeb.Player.TeamFormComponent, {:updated_changeset, %{changes: _changes}}},
        socket
      ) do
    {:noreply, socket}
  end

  def handle_info(
        {DurandalWeb.Player.TeamMemberQuickAddComponent,
         {:updated_changeset, %{changes: _changes}}},
        socket
      ) do
    {:noreply, socket}
  end

  @spec get_team(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_team(%{assigns: %{team_id: team_id}} = socket) do
    team = Player.get_team!(team_id, preload: [:universe])

    team_members =
      Player.list_team_members(
        where: [team_id: team_id],
        preload: [:user],
        oorder_by: ["Name (A-Z)"]
      )
      |> Enum.map(fn tm -> Map.put(tm, :id, tm.user_id) end)

    stations = Space.list_stations(where: [team_id: team_id], order_by: ["Name (A-Z)"])
    ships = Space.list_ships(where: [team_id: team_id], order_by: ["Name (A-Z)"])

    socket
    |> assign(:team, team)
    |> stream(:team_members, team_members, reset: true)
    |> stream(:ships, ships, reset: true)
    |> stream(:stations, stations, reset: true)
    |> assign(:universe, team.universe)
  end
end
