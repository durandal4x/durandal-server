defmodule DurandalWeb.Admin.Types.SystemObjectType.ShowLive do
  @moduledoc false
  use DurandalWeb, :live_view
  alias Durandal.Types

  @impl true
  def mount(%{"system_object_type_id" => system_object_type_id}, _session, socket)
      when is_connected?(socket) do
    socket =
      socket
      |> assign(:site_menu_active, "game")
      |> assign(:system_object_type_id, system_object_type_id)
      |> get_system_object_type()

    if socket.assigns.system_object_type do
      :ok = Durandal.subscribe(Types.system_object_type_topic(system_object_type_id))

      {:ok, socket}
    else
      {:ok, redirect(socket, to: ~p"/admin/games")}
    end
  end

  def mount(_params, _session, socket) do
    socket
    |> assign(:site_menu_active, "game")
    |> assign(:system_object_type_id, nil)
    |> assign(:system_object_type, nil)
    |> stream(:system_object_type_members, [])
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
    Durandal.Types.DeleteSystemObjectTypeTask.perform(socket.assigns.system_object_type_id)

    socket
    |> redirect(to: ~p"/admin/system_object_types")
    |> put_flash(:info, "SystemObjectType deleted")
    |> noreply
  end

  @impl true
  def handle_info(
        {DurandalWeb.Types.SystemObjectTypeFormComponent,
         {:updated_changeset, %{changes: _changes}}},
        socket
      ) do
    {:noreply, socket}
  end

  @spec get_system_object_type(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_system_object_type(
         %{assigns: %{system_object_type_id: system_object_type_id}} = socket
       ) do
    system_object_type =
      Types.get_system_object_type!(system_object_type_id, preload: [:universe])

    socket
    |> assign(:system_object_type, system_object_type)
    |> assign(:universe, system_object_type.universe)
  end
end
