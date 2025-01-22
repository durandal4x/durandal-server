defmodule DurandalWeb.Admin.Game.Universe.IndexLive do
  @moduledoc false
  use DurandalWeb, :live_view

  alias Durandal.Game

  @impl true
  def mount(_params, _session, socket) when is_connected?(socket) do
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
     |> assign(:universes, [])}
  end

  @impl true
  def handle_event("update-search", %{"value" => search_term}, socket) do
    socket
    |> assign(:search_term, search_term)
    |> get_universes
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
    |> assign(:universes, universes)
  end
end
