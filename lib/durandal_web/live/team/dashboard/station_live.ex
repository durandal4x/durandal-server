defmodule DurandalWeb.Team.StationLive do
  @moduledoc false
  use DurandalWeb, :live_view
  alias Durandal.{Space, Player, Types}

  @impl true
  def mount(%{"station_id" => station_id}, _session, socket) when is_connected?(socket) do
    :ok = Durandal.subscribe(Space.station_topic(station_id))

    socket =
      socket
      |> assign(:station_id, station_id)
      |> get_station()
      |> assign(:ship_lookup, %{})
      |> assign(:station_lookup, %{})
      |> assign(:system_object_lookup, %{})
      |> assign(:ship_type_lookup, %{})
      |> assign(:station_module_type_lookup, %{})
      |> initial_uuid_lookup

    if socket.assigns.station do
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
    |> assign(:ship_type_lookup, nil)
    |> assign(:station_module_type_lookup, nil)
    |> ok
  end

  @impl true
  def handle_event("cancel-command", %{"command_id" => id}, socket) do
    Player.get_command!(id)
    |> Player.delete_command()

    socket
    |> get_station
    |> noreply
  end

  def handle_event("command-lower-order", %{"command_id" => id}, socket) do
    Player.CommandLib.decrease_command_ordering(id, socket.assigns.ship_id)

    socket
    |> get_station
    |> noreply
  end

  def handle_event("command-higher-order", %{"command_id" => id}, socket) do
    Player.CommandLib.increase_command_ordering(id, socket.assigns.ship_id)

    socket
    |> get_station
    |> noreply
  end

  @impl true
  # Station updates
  def handle_info(
        %{event: :updated_station, topic: "Durandal.Space.Station:" <> _} = _msg,
        socket
      ) do
    socket
    |> get_station
    |> noreply
  end

  def handle_info(%{event: :deleted_station, topic: "Durandal.Space.Station" <> _} = _msg, socket) do
    socket
    |> redirect(to: ~p"/team/dashboard")
    |> noreply
  end

  def handle_info(
        %{event: :created_station_module, topic: "Durandal.Space.Station" <> _} = _msg,
        socket
      ) do
    socket
    |> get_station
    |> noreply
  end

  def handle_info(
        %{event: :updated_station_module, topic: "Durandal.Space.Station" <> _} = _msg,
        socket
      ) do
    socket
    |> get_station
    |> noreply
  end

  def handle_info(
        {DurandalWeb.Player.StationCommandAddComponent,
         {:updated_changeset, %{changes: _changes}}},
        socket
      ) do
    {:noreply, socket}
  end

  def handle_info(
        {DurandalWeb.Player.StationCommandAddComponent,
         {:saved, %Durandal.Player.Command{} = cmd}},
        socket
      ) do
    # We don't know for certain this will be a uuid, this allows us
    # to only have UUIDs
    uuids =
      Map.values(cmd.contents || %{})
      |> Enum.reject(&is_nil(&1))
      |> Enum.filter(fn maybe_uuid ->
        case Ecto.UUID.cast(maybe_uuid) do
          {:ok, _} -> true
          _ -> false
        end
      end)

    socket
    |> get_station
    |> extend_id_lookup(uuids)
    |> noreply
  end

  @spec get_station(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_station(%{assigns: %{station_id: station_id}} = socket) do
    station =
      Space.get_station!(station_id,
        preload: [:team, :system, :orbiting, :incomplete_commands, :transfer_with_destination]
      )

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
    |> stream(:station_modules, station_modules, reset: true)
    |> stream(:docked_ships, docked_ships, reset: true)
    |> assign(:page_title, "Station: #{station.name}")
  end

  defp initial_uuid_lookup(%{assigns: %{station: station}} = socket) do
    uuids =
      station.commands
      |> Enum.map(fn cmd -> Map.values(cmd.contents || %{}) end)
      |> List.flatten()
      |> Enum.reject(&is_nil(&1))
      |> Enum.filter(fn maybe_uuid ->
        case Ecto.UUID.cast(maybe_uuid) do
          {:ok, _} -> true
          _ -> false
        end
      end)

    socket
    |> extend_id_lookup(uuids)
  end

  defp extend_id_lookup(socket, new_ids) do
    ships =
      Space.list_ships(
        where: [
          id: new_ids,
          universe_id: socket.assigns.current_universe.id
        ]
      )
      |> Map.new(fn s -> {s.id, s} end)

    stations =
      Space.list_stations(
        where: [
          id: new_ids,
          universe_id: socket.assigns.current_universe.id
        ]
      )
      |> Map.new(fn s -> {s.id, s} end)

    system_objects =
      Space.list_system_objects(
        where: [
          id: new_ids,
          universe_id: socket.assigns.current_universe.id
        ]
      )
      |> Map.new(fn s -> {s.id, s} end)

    ship_types =
      Types.list_ship_types(
        where: [
          id: new_ids,
          universe_id: socket.assigns.current_universe.id
        ]
      )
      |> Map.new(fn s -> {s.id, s} end)

    station_module_types =
      Types.list_station_module_types(
        where: [
          id: new_ids,
          universe_id: socket.assigns.current_universe.id
        ]
      )
      |> Map.new(fn s -> {s.id, s} end)

    socket
    |> assign(:ship_lookup, Map.merge(socket.assigns.ship_lookup, ships))
    |> assign(:station_lookup, Map.merge(socket.assigns.station_lookup, stations))
    |> assign(
      :system_object_lookup,
      Map.merge(socket.assigns.system_object_lookup, system_objects)
    )
    |> assign(:ship_type_lookup, Map.merge(socket.assigns.ship_type_lookup, ship_types))
    |> assign(
      :station_module_type_lookup,
      Map.merge(socket.assigns.station_module_type_lookup, station_module_types)
    )
  end
end
