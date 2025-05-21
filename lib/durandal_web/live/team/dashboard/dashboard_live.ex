defmodule DurandalWeb.Team.DashboardLive do
  use DurandalWeb, :live_view

  alias Durandal.{Space, Player, Resources}

  @impl true
  def mount(_params, _session, socket) when is_connected?(socket) do
    :ok = Durandal.subscribe(Player.team_topic(socket.assigns.current_team.id))

    socket
    |> get_data
    |> assign(:site_menu_active, "team")
    |> ok
  end

  def mount(_params, _session, socket) do
    socket
    |> stream(:ships, [])
    |> stream(:stations, [])
    |> assign(:site_menu_active, "team")
    |> ok
  end

  defp get_data(%{assigns: %{current_team: team}} = socket) do
    stations = Space.list_stations(where: [team_id: team.id], order_by: ["Name (A-Z)"])

    ships =
      Space.list_ships(where: [team_id: team.id], order_by: ["Name (A-Z)"], preload: [:type])

    {simple_resources, composite_resources} = Resources.list_all_team_resources(team.id)

    type_ids =
      Resources.get_types_from_team_resources(team.id)
      |> Enum.map(&Ecto.UUID.load!/1)

    resource_types =
      Resources.list_resources_simple_types(where: [id: type_ids])
      |> Map.new(fn t -> {t.id, t} end)

    combined_simple =
      simple_resources
      |> Enum.group_by(& &1.type_id)
      |> Enum.map(fn {type_id, instances} ->
        total_quantity =
          instances
          |> Enum.reduce(0, fn instance, acc ->
            acc + instance.quantity
          end)

        %{
          type_id: type_id,
          quantity: total_quantity
        }
      end)

    combined_composite =
      composite_resources
      |> Enum.group_by(fn r -> {r.type_id, r.type, r.ratios, r.averaged_mass} end)
      |> Enum.map(fn {{type_id, type, ratios, averaged_mass}, instances} ->
        total_quantity =
          instances
          |> Enum.reduce(0, fn instance, acc ->
            acc + instance.quantity
          end)

        %{
          type_id: type_id,
          type: type,
          ratios: ratios,
          averaged_mass: averaged_mass,
          quantity: total_quantity
        }
      end)

    socket
    |> stream(:ships, ships, reset: true)
    |> stream(:stations, stations, reset: true)
    |> assign(:simple_resources, simple_resources)
    |> assign(:composite_resources, composite_resources)
    |> assign(:combined_simple, combined_simple)
    |> assign(:combined_composite, combined_composite)
    |> assign(:resource_types, resource_types)
  end

  @impl true
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
    ship =
      msg.ship
      |> Map.put(:type, Durandal.Types.get_ship_type_by_id(msg.ship.type_id))

    socket
    |> stream_insert(:ships, ship)
    |> noreply
  end

  def handle_info(%{event: :updated_ship, topic: "Durandal.Player.Team:" <> _} = msg, socket) do
    ship = Space.get_extended_ship(msg.ship.id)

    socket
    |> stream_insert(:ships, ship)
    |> noreply
  end

  def handle_info(%{event: :deleted_ship, topic: "Durandal.Player.Team" <> _} = msg, socket) do
    socket
    |> stream_delete(:ships, msg.ship)
    |> noreply
  end

  def handle_info(%{topic: "Durandal.Player.Team" <> _}, socket) do
    socket
    |> noreply
  end
end
