defmodule DurandalWeb.Admin.Types.StationModuleType.ShowLive do
  @moduledoc false
  use DurandalWeb, :live_view
  alias Durandal.Types

  @impl true
  def mount(%{"station_module_type_id" => station_module_type_id}, _session, socket)
      when is_connected?(socket) do
    socket =
      socket
      |> assign(:site_menu_active, "game")
      |> assign(:station_module_type_id, station_module_type_id)
      |> get_station_module_type()

    if socket.assigns.station_module_type do
      :ok = Durandal.subscribe(Types.station_module_type_topic(station_module_type_id))

      {:ok, socket}
    else
      {:ok, redirect(socket, to: ~p"/admin/games")}
    end
  end

  def mount(_params, _session, socket) do
    socket
    |> assign(:site_menu_active, "game")
    |> assign(:station_module_type_id, nil)
    |> assign(:station_module_type, nil)
    |> stream(:station_module_type_members, [])
    |> stream(:stations, [])
    |> stream(:ships, [])
    |> ok
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, _params) do
    socket
    |> assign(:edit_mode, true)
  end

  defp apply_action(socket, _, _params) do
    socket
    |> assign(:edit_mode, false)
  end

  @impl true
  def handle_event("delete", _params, socket) do
    Durandal.Types.DeleteStationModuleTypeTask.perform(socket.assigns.station_module_type_id)

    socket
    |> redirect(to: ~p"/admin/station_module_types")
    |> put_flash(:info, "StationModuleType deleted")
    |> noreply
  end

  @impl true
  def handle_info(
        {DurandalWeb.Types.StationModuleTypeFormComponent,
         {:updated_changeset, %{changes: _changes}}},
        socket
      ) do
    {:noreply, socket}
  end

  @spec get_station_module_type(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_station_module_type(
         %{assigns: %{station_module_type_id: station_module_type_id}} = socket
       ) do
    station_module_type =
      Types.get_station_module_type!(station_module_type_id, preload: [:universe])

    socket
    |> assign(:station_module_type, station_module_type)
    |> assign(:universe, station_module_type.universe)
  end
end
