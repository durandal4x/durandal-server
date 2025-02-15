defmodule DurandalWeb.Admin.Space.StationModule.IndexLive do
  @moduledoc false
  use DurandalWeb, :live_view

  alias Durandal.Space

  @impl true
  def mount(_params, _session, socket) when is_connected?(socket) do
    # :ok = Durandal.subscribe(Game.station_module_global_topic())

    socket
    |> assign(:site_menu_active, "game")
    |> assign(:search_term, "")
    |> get_station_modules
    |> ok
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:site_menu_active, "game")
     |> stream(:station_modules, [])}
  end

  @impl true
  def handle_event("update-search", %{"value" => search_term}, socket) do
    socket
    |> assign(:search_term, search_term)
    |> get_station_modules
    |> noreply
  end

  @impl true
  def handle_info(
        %{event: :created_station_module, topic: "Durandal.Global.StationModule"} = msg,
        socket
      ) do
    socket
    |> stream_insert(:station_modules, msg.station_module)
    |> noreply
  end

  def handle_info(
        %{event: :updated_station_module, topic: "Durandal.Global.StationModule"} = msg,
        socket
      ) do
    socket
    |> stream_insert(:station_modules, msg.station_module)
    |> noreply
  end

  def handle_info(
        %{event: :deleted_station_module, topic: "Durandal.Global.StationModule"} = msg,
        socket
      ) do
    socket
    |> stream_delete(:station_modules, msg.station_module)
    |> noreply
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @spec get_station_modules(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_station_modules(%{assigns: assigns} = socket) do
    order_by =
      if assigns.search_term != "" do
        "Name (A-Z)"
      else
        "Newest first"
      end

    station_modules =
      Space.list_station_modules(
        where: [name_like: assigns.search_term],
        order_by: order_by,
        limit: 50,
        preload: [:type]
      )

    socket
    |> stream(:station_modules, station_modules, reset: true)
  end
end
