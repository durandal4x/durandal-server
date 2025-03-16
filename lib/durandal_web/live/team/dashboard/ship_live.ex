defmodule DurandalWeb.Team.ShipLive do
  @moduledoc false
  use DurandalWeb, :live_view
  alias Durandal.Space

  @impl true
  def mount(%{"ship_id" => ship_id}, _session, socket) when is_connected?(socket) do
    socket =
      socket
      |> assign(:ship_id, ship_id)
      |> get_ship()

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
  def handle_event(_msg, _params, socket) do
    socket
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
    |> redirect(to: ~p"/team/dashboard")
    |> noreply
  end

  def handle_info(
        {DurandalWeb.Player.ShipCommandAddComponent,
         {:updated_changeset, %{changes: _changes}}},
        socket
      ) do
    {:noreply, socket}
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
    ship = Space.get_ship!(ship_id, preload: [:type, :system, :orbiting, :docked_with, :commands])

    socket
    |> assign(:ship, ship)
    |> assign(:page_title, "Ship: #{ship.name}")
  end
end
