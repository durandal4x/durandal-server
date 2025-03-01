defmodule DurandalWeb.Admin.Types.ShipType.ShowLive do
  @moduledoc false
  use DurandalWeb, :live_view
  alias Durandal.Types

  @impl true
  def mount(%{"ship_type_id" => ship_type_id}, _session, socket) when is_connected?(socket) do
    socket =
      socket
      |> assign(:site_menu_active, "game")
      |> assign(:ship_type_id, ship_type_id)
      |> get_ship_type()

    if socket.assigns.ship_type do
      :ok = Durandal.subscribe(Types.ship_type_topic(ship_type_id))

      {:ok, socket}
    else
      {:ok, redirect(socket, to: ~p"/admin/games")}
    end
  end

  def mount(_params, _session, socket) do
    socket
    |> assign(:site_menu_active, "game")
    |> assign(:ship_type_id, nil)
    |> assign(:ship_type, nil)
    |> stream(:ship_type_members, [])
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
    Durandal.Types.DeleteShipTypeTask.perform(socket.assigns.ship_type_id)

    socket
    |> redirect(to: ~p"/admin/ship_types")
    |> put_flash(:info, "ShipType deleted")
    |> noreply
  end

  @impl true
  def handle_info(
        {DurandalWeb.Types.ShipTypeFormComponent, {:updated_changeset, %{changes: _changes}}},
        socket
      ) do
    {:noreply, socket}
  end

  @spec get_ship_type(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_ship_type(%{assigns: %{ship_type_id: ship_type_id}} = socket) do
    ship_type = Types.get_ship_type!(ship_type_id, preload: [:universe])

    socket
    |> assign(:ship_type, ship_type)
    |> assign(:universe, ship_type.universe)
  end
end
