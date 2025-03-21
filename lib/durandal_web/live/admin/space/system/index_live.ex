defmodule DurandalWeb.Admin.Space.System.IndexLive do
  @moduledoc false
  use DurandalWeb, :live_view

  alias Durandal.Space

  @impl true
  def mount(%{"universe_id" => universe_id}, _session, socket) when is_connected?(socket) do
    socket
    |> assign(:universe_id, universe_id)
    |> assign(:site_menu_active, "game")
    |> assign(:search_term, "")
    |> get_systems
    |> ok
  end

  def mount(%{"universe_id" => universe_id}, _session, socket) do
    {:ok,
     socket
     |> assign(:universe_id, universe_id)
     |> assign(:site_menu_active, "game")
     |> assign(:systems, [])}
  end

  @impl true
  def handle_event("update-search", %{"value" => search_term}, socket) do
    socket
    |> assign(:search_term, search_term)
    |> get_systems
    |> noreply
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @spec get_systems(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_systems(%{assigns: assigns} = socket) do
    order_by =
      if assigns.search_term != "" do
        "Name (A-Z)"
      else
        "Newest first"
      end

    systems =
      Space.list_systems(
        where: [universe_id: assigns.universe_id, name_like: assigns.search_term],
        order_by: order_by,
        limit: 50
      )

    socket
    |> assign(:systems, systems)
  end
end
