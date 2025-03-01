defmodule DurandalWeb.Admin.Game.Universe.IndexLive do
  @moduledoc false
  use DurandalWeb, :live_view

  alias Durandal.Game

  @impl true
  def mount(_params, _session, socket) when is_connected?(socket) do
    :ok = Durandal.subscribe(Game.universe_global_topic())

    socket
    |> assign(:site_menu_active, "game")
    |> assign(:search_term, "")
    |> get_universes
    |> ok
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:site_menu_active, "game")
     |> stream(:universes, [])}
  end

  @impl true
  def handle_event("update-search", %{"value" => search_term}, socket) do
    socket
    |> assign(:search_term, search_term)
    |> get_universes
    |> noreply
  end

  @impl true
  def handle_info(%{event: :created_universe, topic: "Durandal.Global.Universe"} = msg, socket) do
    socket
    |> stream_insert(:universes, msg.universe)
    |> noreply
  end

  def handle_info(%{event: :updated_universe, topic: "Durandal.Global.Universe"} = msg, socket) do
    socket
    |> stream_insert(:universes, msg.universe)
    |> noreply
  end

  def handle_info(%{event: :deleted_universe, topic: "Durandal.Global.Universe"} = msg, socket) do
    socket
    |> stream_delete(:universes, msg.universe)
    |> noreply
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @spec get_universes(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_universes(%{assigns: assigns} = socket) do
    order_by =
      if assigns.search_term != "" do
        "Name (A-Z)"
      else
        "Newest first"
      end

    universes =
      Game.list_universes(where: [name_like: assigns.search_term], order_by: order_by, limit: 50)

    socket
    |> stream(:universes, universes, reset: true)
  end
end
