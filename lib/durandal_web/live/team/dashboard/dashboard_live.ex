defmodule DurandalWeb.Team.DashboardLive do
  use DurandalWeb, :live_view

  alias Durandal.{Space, Player, Resources}

  @impl true
  def mount(_params, _session, socket) when is_connected?(socket) do
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

  defp get_data(%{assigns: %{current_team: nil}} = socket) do
    socket
  end

  defp get_data(%{assigns: %{current_team: team}} = socket) do
    :ok = Durandal.subscribe(Player.team_topic(team.id))

    stations = Space.list_stations(where: [team_id: team.id], order_by: ["Name (A-Z)"])

    ships =
      Space.list_ships(where: [team_id: team.id], order_by: ["Name (A-Z)"], preload: [:type])

    {simple_resources, composite_resources} = Resources.list_all_team_resources(team.id)

    combined_simple = Resources.combine_instances_by_type(simple_resources)
    combined_composite = Resources.combine_instances_by_type(composite_resources)

    socket
    |> stream(:ships, ships, reset: true)
    |> stream(:stations, stations, reset: true)
    |> assign(:simple_resources, simple_resources)
    |> assign(:composite_resources, composite_resources)
    |> assign(:combined_simple, combined_simple)
    |> assign(:combined_composite, combined_composite)
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
