defmodule DurandalWeb.Team.ShipLive do
  @moduledoc false
  use DurandalWeb, :live_view
  alias Durandal.{Space, Player, Resources}

  @impl true
  def mount(%{"ship_id" => ship_id}, _session, socket) when is_connected?(socket) do
    :ok = Durandal.subscribe(Space.ship_topic(ship_id))

    socket =
      socket
      |> assign(:ship_id, ship_id)
      |> get_ship()
      |> assign(:ship_lookup, %{})
      |> assign(:station_lookup, %{})
      |> assign(:system_object_lookup, %{})
      |> initial_uuid_lookup

    if socket.assigns.ship do
      {:ok, socket}
    else
      {:ok, redirect(socket, to: ~p"/admin/games")}
    end
  end

  def mount(_params, _session, socket) do
    socket
    |> assign(:site_menu_active, "game")
    |> assign(:ship_id, nil)
    |> assign(:ship, nil)
    |> ok
  end

  @impl true
  def handle_event("cancel-command", %{"command_id" => id}, socket) do
    Player.get_command!(id)
    |> Player.delete_command()

    socket
    |> get_ship
    |> noreply
  end

  def handle_event("command-lower-order", %{"command_id" => id}, socket) do
    Player.CommandLib.decrease_command_ordering(id, socket.assigns.ship_id)

    socket
    |> get_ship
    |> noreply
  end

  def handle_event("command-higher-order", %{"command_id" => id}, socket) do
    Player.CommandLib.increase_command_ordering(id, socket.assigns.ship_id)

    socket
    |> get_ship
    |> noreply
  end

  @impl true
  # Ship updates
  def handle_info(%{event: :updated_ship, topic: "Durandal.Space.Ship:" <> _} = _msg, socket) do
    socket
    |> get_ship
    |> noreply
  end

  def handle_info(%{event: :deleted_ship, topic: "Durandal.Space.Ship" <> _} = _msg, socket) do
    socket
    |> redirect(to: ~p"/team/dashboard")
    |> noreply
  end

  def handle_info(
        {DurandalWeb.Player.ShipCommandAddComponent, {:updated_changeset, %{changes: _changes}}},
        socket
      ) do
    {:noreply, socket}
  end

  def handle_info(
        {DurandalWeb.Player.ShipCommandAddComponent, {:saved, %Durandal.Player.Command{} = cmd}},
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
    |> get_ship
    |> extend_id_lookup(uuids)
    |> noreply
  end

  def handle_info(
        {DurandalWeb.Player.StationCommandAddComponent,
         {:updated_changeset, %{changes: _changes}}},
        socket
      ) do
    {:noreply, socket}
  end

  @spec get_ship(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_ship(%{assigns: %{ship_id: ship_id}} = socket) do
    ship =
      Space.get_ship!(ship_id,
        preload: [
          :type,
          :system,
          :orbiting,
          :docked_with,
          :incomplete_commands,
          :cargo
        ]
      )

    type_ids =
      Resources.get_types_from_ship_resources(ship_id)
      |> Enum.map(&Ecto.UUID.load!/1)

    resource_types =
      Resources.list_resources_simple_types(where: [id: type_ids])
      |> Map.new(fn t -> {t.id, t} end)

    socket
    |> assign(:ship, ship)
    |> assign(:resource_types, resource_types)
    |> assign(:page_title, "Ship: #{ship.name}")
  end

  defp initial_uuid_lookup(%{assigns: %{ship: ship}} = socket) do
    uuids =
      ship.commands
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

    socket
    |> assign(:ship_lookup, Map.merge(socket.assigns.ship_lookup, ships))
    |> assign(:station_lookup, Map.merge(socket.assigns.station_lookup, stations))
    |> assign(
      :system_object_lookup,
      Map.merge(socket.assigns.system_object_lookup, system_objects)
    )
  end
end
