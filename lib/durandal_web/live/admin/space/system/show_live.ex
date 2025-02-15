defmodule DurandalWeb.Admin.Space.System.ShowLive do
  @moduledoc false
  use DurandalWeb, :live_view
  alias Durandal.{Space, Player}

  @impl true
  def mount(%{"system_id" => system_id}, _session, socket) when is_connected?(socket) do
    socket =
      socket
      |> assign(:site_menu_active, "game")
      |> assign(:system_id, system_id)
      |> get_system()

    if socket.assigns.system do
      :ok = Durandal.subscribe(Space.system_topic(system_id))

      {:ok, socket}
    else
      {:ok, redirect(socket, to: ~p"/admin/games")}
    end
  end

  def mount(_params, _session, socket) do
    socket
    |> assign(:site_menu_active, "game")
    |> assign(:system_id, nil)
    |> assign(:system, nil)
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
  # System updates
  def handle_info(%{event: :updated_system, topic: "Durandal.Space.System:" <> _} = msg, socket) do
    socket
    |> assign(:system, msg.system)
    |> noreply
  end

  def handle_info(%{event: :deleted_system, topic: "Durandal.Space.System" <> _} = msg, socket) do
    socket
    |> redirect(to: ~p"/admin/systems")
    |> noreply
  end

  # SystemObject updates
  def handle_info(
        %{event: :created_system_object, topic: "Durandal.Space.System:" <> _} = msg,
        socket
      ) do
    socket
    |> stream_insert(:system_objects, msg.system_object)
    |> noreply
  end

  def handle_info(
        %{event: :updated_system_object, topic: "Durandal.Space.System:" <> _} = msg,
        socket
      ) do
    socket
    |> stream_insert(:system_objects, msg.system_object)
    |> noreply
  end

  def handle_info(
        %{event: :deleted_system_object, topic: "Durandal.Space.System" <> _} = msg,
        socket
      ) do
    socket
    |> stream_delete(:system_objects, msg.system_object)
    |> noreply
  end

  # Station updates
  def handle_info(%{event: :created_station, topic: "Durandal.Space.System:" <> _} = msg, socket) do
    socket
    |> stream_insert(:stations, msg.station)
    |> noreply
  end

  def handle_info(%{event: :updated_station, topic: "Durandal.Space.System:" <> _} = msg, socket) do
    socket
    |> stream_insert(:stations, msg.station)
    |> noreply
  end

  def handle_info(%{event: :deleted_station, topic: "Durandal.Space.System" <> _} = msg, socket) do
    socket
    |> stream_delete(:stations, msg.station)
    |> noreply
  end

  # Ship updates
  def handle_info(%{event: :created_ship, topic: "Durandal.Space.System:" <> _} = msg, socket) do
    socket
    |> stream_insert(:ships, msg.ship)
    |> noreply
  end

  def handle_info(%{event: :updated_ship, topic: "Durandal.Space.System:" <> _} = msg, socket) do
    socket
    |> stream_insert(:ships, msg.ship)
    |> noreply
  end

  def handle_info(%{event: :deleted_ship, topic: "Durandal.Space.System" <> _} = msg, socket) do
    socket
    |> stream_delete(:ships, msg.ship)
    |> noreply
  end

  def handle_info(
        {DurandalWeb.Space.SystemFormComponent, {:updated_changeset, %{changes: _changes}}},
        socket
      ) do
    {:noreply, socket}
  end

  @spec get_system(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_system(%{assigns: %{system_id: system_id}} = socket) do
    system = Durandal.Space.get_system!(system_id, preload: [:universe])

    objects =
      Durandal.Space.list_system_objects(where: [system_id: system_id], order_by: ["Name (A-Z)"])

    ships = Durandal.Space.list_ships(where: [system_id: system_id], order_by: ["Name (A-Z)"])

    stations =
      Durandal.Space.list_stations(where: [system_id: system_id], order_by: ["Name (A-Z)"])

    socket
    |> assign(:system, system)
    |> assign(:universe, system.universe)
    |> stream(:system_objects, objects, reset: true)
    |> stream(:ships, ships, reset: true)
    |> stream(:stations, stations, reset: true)
  end
end
