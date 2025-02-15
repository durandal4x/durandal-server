defmodule DurandalWeb.Admin.Space.SystemObject.ShowLive do
  @moduledoc false
  use DurandalWeb, :live_view
  alias Durandal.{Space, Space, Types}

  @impl true
  def mount(%{"system_object_id" => system_object_id}, _session, socket)
      when is_connected?(socket) do
    socket =
      socket
      |> assign(:site_menu_active, "game")
      |> assign(:system_object_id, system_object_id)
      |> get_system_object()

    if socket.assigns.system_object do
      # :ok = Durandal.subscribe(Space.system_object_topic(system_object_id))

      {:ok, socket}
    else
      {:ok, redirect(socket, to: ~p"/admin/games")}
    end
  end

  def mount(_params, _session, socket) do
    socket
    |> assign(:site_menu_active, "game")
    |> assign(:system_object_id, nil)
    |> assign(:system_object, nil)
    |> stream(:ships, [])
    |> ok
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, _params) do
    type_list =
      Types.list_system_object_types(order_by: ["Name (A-Z)"], select: ~w(name id)a)
      |> Enum.map(fn t -> {t.name, t.id} end)

    system_list =
      Space.list_systems(order_by: ["Name (A-Z)"], select: ~w(name id)a)
      |> Enum.map(fn t -> {t.name, t.id} end)

    socket
    |> assign(:edit_mode, true)
    |> assign(:type_list, type_list)
    |> assign(:system_list, system_list)
  end

  defp apply_action(socket, _, _params) do
    socket
    |> assign(:edit_mode, false)
  end

  @impl true
  def handle_event("delete", _params, socket) do
    Durandal.Space.DeleteSystemObjectTask.perform(socket.assigns.system_object_id)

    socket
    |> redirect(to: ~p"/admin/system_objects")
    |> put_flash(:info, "SystemObject deleted")
    |> noreply
  end

  @impl true
  # SystemObject updates
  def handle_info(
        %{event: :updated_system_object, topic: "Durandal.Space.SystemObject:" <> _} = msg,
        socket
      ) do
    socket
    |> assign(:system_object, msg.system_object)
    |> noreply
  end

  def handle_info(
        %{event: :deleted_system_object, topic: "Durandal.Space.SystemObject" <> _} = msg,
        socket
      ) do
    socket
    |> redirect(to: ~p"/admin/system_objects")
    |> noreply
  end

  # System updates
  def handle_info(
        %{event: :created_system, topic: "Durandal.Space.SystemObject:" <> _} = msg,
        socket
      ) do
    socket
    |> stream_insert(:systems, msg.system)
    |> noreply
  end

  def handle_info(
        %{event: :updated_system, topic: "Durandal.Space.SystemObject:" <> _} = msg,
        socket
      ) do
    socket
    |> stream_insert(:systems, msg.system)
    |> noreply
  end

  def handle_info(
        %{event: :deleted_system, topic: "Durandal.Space.SystemObject" <> _} = msg,
        socket
      ) do
    socket
    |> stream_delete(:systems, msg.system)
    |> noreply
  end

  # SystemObject updates
  def handle_info(
        %{event: :created_system_object, topic: "Durandal.Space.SystemObject:" <> _} = msg,
        socket
      ) do
    socket
    |> stream_insert(:system_objects, msg.system_object)
    |> noreply
  end

  def handle_info(
        %{event: :updated_system_object, topic: "Durandal.Space.SystemObject:" <> _} = msg,
        socket
      ) do
    socket
    |> stream_insert(:system_objects, msg.system_object)
    |> noreply
  end

  def handle_info(
        %{event: :deleted_system_object, topic: "Durandal.Space.SystemObject" <> _} = msg,
        socket
      ) do
    socket
    |> stream_delete(:system_objects, msg.system_object)
    |> noreply
  end

  def handle_info(
        {DurandalWeb.Space.SystemObjectFormComponent, {:updated_changeset, %{changes: _changes}}},
        socket
      ) do
    {:noreply, socket}
  end

  @spec get_system_object(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_system_object(%{assigns: %{system_object_id: system_object_id}} = socket) do
    system_object =
      Space.get_system_object!(system_object_id, preload: [:type, :system, :orbiting])

    # ships = Space.list_ships(where: [system_object_id: system_object_id], order_by: ["Name (A-Z)"])
    ships = []

    socket
    |> assign(:system_object, system_object)
    |> stream(:ships, ships, reset: true)
  end
end
