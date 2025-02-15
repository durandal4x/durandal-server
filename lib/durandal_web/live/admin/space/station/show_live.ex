defmodule DurandalWeb.Admin.Space.Station.ShowLive do
  @moduledoc false
  use DurandalWeb, :live_view
  alias Durandal.{Space, Player}

  @impl true
  def mount(%{"station_id" => station_id}, _session, socket) when is_connected?(socket) do
    socket =
      socket
      |> assign(:site_menu_active, "game")
      |> assign(:station_id, station_id)
      |> get_station()

    if socket.assigns.station do
      :ok = Durandal.subscribe(Space.station_topic(station_id))

      {:ok, socket}
    else
      {:ok, redirect(socket, to: ~p"/admin/games")}
    end
  end

  def mount(_params, _session, socket) do
    socket
    |> assign(:site_menu_active, "game")
    |> assign(:station_id, nil)
    |> assign(:station, nil)
    |> stream(:station_modules, [])
    |> ok
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(%{assigns: %{station: station}} = socket, :edit, _params) do
    if station do
      system_list =
        Space.list_systems(
          where: [universe_id: station.system.universe_id],
          order_by: ["Name (A-Z)"],
          select: ~w(name id)a
        )
        |> Enum.map(fn s -> {s.name, s.id} end)

      team_list =
        Player.list_teams(
          where: [universe_id: station.system.universe_id],
          order_by: ["Name (A-Z)"],
          select: ~w(name id)a
        )
        |> Enum.map(fn t -> {t.name, t.id} end)

      socket
      |> assign(:system_list, system_list)
      |> assign(:team_list, team_list)
    else
      socket
    end
    |> assign(:edit_mode, true)
  end

  defp apply_action(socket, _, _params) do
    socket
    |> assign(:edit_mode, false)
  end

  @impl true
  def handle_event("delete", _params, socket) do
    Durandal.Space.DeleteStationTask.perform(socket.assigns.station_id)

    socket
    |> redirect(to: ~p"/admin/stations")
    |> put_flash(:info, "Station deleted")
    |> noreply
  end

  @impl true
  # Station updates
  def handle_info(%{event: :updated_station, topic: "Durandal.Space.Station:" <> _} = msg, socket) do
    socket
    |> assign(:station, msg.station)
    |> noreply
  end

  def handle_info(%{event: :deleted_station, topic: "Durandal.Space.Station" <> _} = msg, socket) do
    socket
    |> redirect(to: ~p"/admin/stations")
    |> noreply
  end

  # StationModule updates
  def handle_info(
        %{event: :created_station_module, topic: "Durandal.Space.Station:" <> _} = msg,
        socket
      ) do
    socket
    |> stream_insert(:station_modules, msg.station_module)
    |> noreply
  end

  def handle_info(
        %{event: :updated_station_module, topic: "Durandal.Space.Station:" <> _} = msg,
        socket
      ) do
    socket
    |> stream_insert(:station_modules, msg.station_module)
    |> noreply
  end

  def handle_info(
        %{event: :deleted_station_module, topic: "Durandal.Space.Station" <> _} = msg,
        socket
      ) do
    socket
    |> stream_delete(:station_modules, msg.station_module)
    |> noreply
  end

  def handle_info(
        {DurandalWeb.Space.StationFormComponent, {:updated_changeset, %{changes: _changes}}},
        socket
      ) do
    {:noreply, socket}
  end

  @spec get_station(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_station(%{assigns: %{station_id: station_id}} = socket) do
    station =
      Space.get_station!(station_id, preload: [:team, :system, :orbiting])

    station_modules =
      Durandal.Space.list_station_modules(
        where: [station_id: station_id],
        oorder_by: ["Name (A-Z)"],
        preload: [:type]
      )

    socket
    |> assign(:station, station)
    |> assign(:team, station.team)
    |> stream(:station_modules, station_modules, reset: true)
  end
end
