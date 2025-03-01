defmodule DurandalWeb.Admin.Space.StationModule.ShowLive do
  @moduledoc false
  use DurandalWeb, :live_view
  alias Durandal.{Space, Types}

  @impl true
  def mount(%{"station_module_id" => station_module_id}, _session, socket)
      when is_connected?(socket) do
    socket =
      socket
      |> assign(:site_menu_active, "game")
      |> assign(:station_module_id, station_module_id)
      |> get_station_module()

    if socket.assigns.station_module do
      :ok = Durandal.subscribe(Space.station_module_topic(station_module_id))

      {:ok, socket}
    else
      {:ok, redirect(socket, to: ~p"/admin/games")}
    end
  end

  def mount(_params, _session, socket) do
    socket
    |> assign(:site_menu_active, "game")
    |> assign(:station_module_id, nil)
    |> assign(:station_module, nil)
    |> stream(:ships, [])
    |> ok
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(%{assigns: %{station_module: station_module}} = socket, :edit, _params) do
    if station_module do
      station_list =
        Space.list_stations(
          where: [team_id: station_module.station.team_id],
          order_by: ["Name (A-Z)"],
          select: ~w(name id)a
        )
        |> Enum.map(fn s -> {s.name, s.id} end)

      type_list =
        Types.list_station_module_types(
          # where: [universe_id: station_module.station.universe_id],
          order_by: ["Name (A-Z)"],
          select: ~w(name id)a
        )
        |> Enum.map(fn t -> {t.name, t.id} end)

      socket
      |> assign(:station_list, station_list)
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
    Durandal.Space.DeleteStationModuleTask.perform(socket.assigns.station_module_id)

    socket
    |> redirect(to: ~p"/admin/station_modules")
    |> put_flash(:info, "StationModule deleted")
    |> noreply
  end

  @impl true
  # StationModule updates
  def handle_info(
        %{event: :updated_station_module, topic: "Durandal.Space.StationModule:" <> _} = msg,
        socket
      ) do
    socket
    |> assign(:station_module, msg.station_module)
    |> noreply
  end

  def handle_info(
        %{event: :deleted_station_module, topic: "Durandal.Space.StationModule" <> _} = _msg,
        socket
      ) do
    socket
    |> redirect(to: ~p"/admin/station_modules")
    |> noreply
  end

  def handle_info(
        {DurandalWeb.Space.StationModuleFormComponent,
         {:updated_changeset, %{changes: _changes}}},
        socket
      ) do
    {:noreply, socket}
  end

  @spec get_station_module(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_station_module(%{assigns: %{station_module_id: station_module_id}} = socket) do
    station_module =
      Space.get_station_module!(station_module_id, preload: [:station, :type, :universe])

    socket
    |> assign(:universe, station_module.universe)
    |> assign(:station_module, station_module)
  end
end
