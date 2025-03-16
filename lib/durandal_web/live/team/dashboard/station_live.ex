defmodule DurandalWeb.Team.StationLive do
  @moduledoc false
  use DurandalWeb, :live_view
  alias Durandal.Space

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
    |> stream(:docked_ships, [])
    |> ok
  end

  @impl true
  def handle_event(_msg, _params, socket) do
    socket
    |> noreply
  end

  @impl true
  # Station updates
  def handle_info(%{event: :updated_station, topic: "Durandal.Space.Station:" <> _} = _msg, socket) do
    station =
      Space.get_station!(socket.assigns.station_id, preload: [:team, :system, :orbiting, :universe])

    socket
    |> assign(:station, station)
    |> noreply
  end

  def handle_info(%{event: :deleted_station, topic: "Durandal.Space.Station" <> _} = _msg, socket) do
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
      Space.get_station!(station_id, preload: [:team, :system, :orbiting, :universe])

    station_modules =
      Durandal.Space.list_station_modules(
        where: [station_id: station_id],
        oorder_by: ["Name (A-Z)"],
        preload: [:type]
      )

    docked_ships =
      Durandal.Space.list_ships(
        where: [docked_with_id: station_id],
        oorder_by: ["Name (A-Z)"],
        preload: [:type]
      )

    socket
    |> assign(:station, station)
    |> assign(:universe, station.universe)
    |> assign(:team, station.team)
    |> stream(:station_modules, station_modules, reset: true)
    |> stream(:docked_ships, docked_ships, reset: true)
    |> assign(:page_title, "Station: #{station.name}")
  end
end
