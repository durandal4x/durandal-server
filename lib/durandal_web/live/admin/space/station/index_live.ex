defmodule DurandalWeb.Admin.Space.Station.IndexLive do
  @moduledoc false
  use DurandalWeb, :live_view

  alias Durandal.Space

  @impl true
  def mount(_params, _session, socket) when is_connected?(socket) do
    # :ok = Durandal.subscribe(Game.station_global_topic())

    socket
    |> assign(:site_menu_active, "game")
    |> assign(:search_term, "")
    |> get_stations
    |> ok
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:site_menu_active, "game")
     |> stream(:stations, [])}
  end

  @impl true
  def handle_event("update-search", %{"value" => search_term}, socket) do
    socket
    |> assign(:search_term, search_term)
    |> get_stations
    |> noreply
  end

  @impl true
  def handle_info(%{event: :created_station, topic: "Durandal.Global.Station"} = msg, socket) do
    socket
    |> stream_insert(:stations, msg.station)
    |> noreply
  end

  def handle_info(%{event: :updated_station, topic: "Durandal.Global.Station"} = msg, socket) do
    socket
    |> stream_insert(:stations, msg.station)
    |> noreply
  end

  def handle_info(%{event: :deleted_station, topic: "Durandal.Global.Station"} = msg, socket) do
    socket
    |> stream_delete(:stations, msg.station)
    |> noreply
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @spec get_stations(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_stations(%{assigns: assigns} = socket) do
    order_by =
      if assigns.search_term != "" do
        "Name (A-Z)"
      else
        "Newest first"
      end

    stations =
      Space.list_stations(where: [name_like: assigns.search_term], order_by: order_by, limit: 50)

    socket
    |> stream(:stations, stations, reset: true)
  end
end
