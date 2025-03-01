defmodule DurandalWeb.Admin.Space.Ship.IndexLive do
  @moduledoc false
  use DurandalWeb, :live_view

  alias Durandal.Space

  @impl true
  def mount(_params, _session, socket) when is_connected?(socket) do
    # :ok = Durandal.subscribe(Game.ship_global_topic())

    socket
    |> assign(:site_menu_active, "game")
    |> assign(:search_term, "")
    |> get_ships
    |> ok
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:site_menu_active, "game")
     |> stream(:ships, [])}
  end

  @impl true
  def handle_event("update-search", %{"value" => search_term}, socket) do
    socket
    |> assign(:search_term, search_term)
    |> get_ships
    |> noreply
  end

  @impl true
  def handle_info(%{event: :created_ship, topic: "Durandal.Global.Ship"} = msg, socket) do
    socket
    |> stream_insert(:ships, msg.ship)
    |> noreply
  end

  def handle_info(%{event: :updated_ship, topic: "Durandal.Global.Ship"} = msg, socket) do
    socket
    |> stream_insert(:ships, msg.ship)
    |> noreply
  end

  def handle_info(%{event: :deleted_ship, topic: "Durandal.Global.Ship"} = msg, socket) do
    socket
    |> stream_delete(:ships, msg.ship)
    |> noreply
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @spec get_ships(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_ships(%{assigns: assigns} = socket) do
    order_by =
      if assigns.search_term != "" do
        "Name (A-Z)"
      else
        "Newest first"
      end

    ships =
      Space.list_ships(where: [name_like: assigns.search_term], order_by: order_by, limit: 50)

    socket
    |> stream(:ships, ships, reset: true)
  end
end
