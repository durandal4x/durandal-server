defmodule DurandalWeb.Admin.Types.StationModuleType.IndexLive do
  @moduledoc false
  use DurandalWeb, :live_view

  alias Durandal.Types

  @impl true
  def mount(_params, _session, socket) when is_connected?(socket) do
    socket
    |> assign(:site_menu_active, "game")
    |> assign(:search_term, "")
    |> get_station_module_types
    |> ok
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(:station_module_types, [])
     |> assign(:site_menu_active, "game")}
  end

  @impl true
  def handle_event("update-search", %{"value" => search_term}, socket) do
    socket
    |> assign(:search_term, search_term)
    |> noreply
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @spec get_station_module_types(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_station_module_types(%{assigns: assigns} = socket) do
    order_by =
      if assigns.search_term != "" do
        "Name (A-Z)"
      else
        "Newest first"
      end

    station_module_types =
      Types.list_station_module_types(
        where: [name_like: assigns.search_term],
        order_by: order_by,
        limit: assigns[:limit] || 50
      )

    socket
    |> stream(:station_module_types, station_module_types, reset: true)
  end
end
