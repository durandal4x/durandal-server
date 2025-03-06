defmodule DurandalWeb.Admin.Space.Ship.ShowLive do
  @moduledoc false
  use DurandalWeb, :live_view
  alias Durandal.{Space, Types, Player}

  @impl true
  def mount(%{"ship_id" => ship_id}, _session, socket) when is_connected?(socket) do
    socket =
      socket
      |> assign(:site_menu_active, "game")
      |> assign(:ship_id, ship_id)
      |> get_ship()

    if socket.assigns.ship do
      # :ok = Durandal.subscribe(Space.ship_topic(ship_id))

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
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(%{assigns: %{ship: ship}} = socket, :edit, _params) do
    if ship do
      system_list =
        Space.list_systems(
          where: [universe_id: ship.system.universe_id],
          order_by: ["Name (A-Z)"],
          select: ~w(name id)a
        )
        |> Enum.map(fn s -> {s.name, s.id} end)

      type_list =
        Types.list_ship_types(
          where: [universe_id: ship.system.universe_id],
          order_by: ["Name (A-Z)"],
          select: ~w(name id)a
        )
        |> Enum.map(fn t -> {t.name, t.id} end)

      team_list =
        Player.list_teams(
          where: [universe_id: ship.system.universe_id],
          order_by: ["Name (A-Z)"],
          select: ~w(name id)a
        )
        |> Enum.map(fn t -> {t.name, t.id} end)

      socket
      |> assign(:system_list, system_list)
      |> assign(:team_list, team_list)
      |> assign(:type_list, type_list)
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
    Durandal.Space.DeleteShipTask.perform(socket.assigns.ship_id)

    socket
    |> redirect(to: ~p"/admin/ships")
    |> put_flash(:info, "Ship deleted")
    |> noreply
  end

  @impl true
  # Ship updates
  def handle_info(%{event: :updated_ship, topic: "Durandal.Space.Ship:" <> _} = msg, socket) do
    socket
    |> assign(:ship, msg.ship)
    |> noreply
  end

  def handle_info(%{event: :deleted_ship, topic: "Durandal.Space.Ship" <> _} = _msg, socket) do
    socket
    |> redirect(to: ~p"/admin/ships")
    |> noreply
  end

  def handle_info(
        {DurandalWeb.Space.ShipFormComponent, {:updated_changeset, %{changes: _changes}}},
        socket
      ) do
    {:noreply, socket}
  end

  @spec get_ship(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_ship(%{assigns: %{ship_id: ship_id}} = socket) do
    ship = Space.get_ship!(ship_id, preload: [:type, :system, :orbiting, :team, :universe, :docked_with])

    socket
    |> assign(:ship, ship)
    |> assign(:team, ship.team)
    |> assign(:universe, ship.universe)
  end
end
