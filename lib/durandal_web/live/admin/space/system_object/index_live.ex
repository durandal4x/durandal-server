defmodule DurandalWeb.Admin.Space.SystemObject.IndexLive do
  @moduledoc false
  use DurandalWeb, :live_view

  alias Durandal.Space

  @impl true
  def mount(_params, _session, socket) when is_connected?(socket) do
    # :ok = Durandal.subscribe(Game.system_object_global_topic())

    socket
    |> assign(:site_menu_active, "game")
    |> assign(:search_term, "")
    |> get_system_objects
    |> ok
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:site_menu_active, "game")
     |> stream(:system_objects, [])}
  end

  @impl true
  def handle_event("update-search", %{"value" => search_term}, socket) do
    socket
    |> assign(:search_term, search_term)
    |> get_system_objects
    |> noreply
  end

  @impl true
  def handle_info(
        %{event: :created_system_object, topic: "Durandal.Global.SystemObject"} = msg,
        socket
      ) do
    socket
    |> stream_insert(:system_objects, msg.system_object)
    |> noreply
  end

  def handle_info(
        %{event: :updated_system_object, topic: "Durandal.Global.SystemObject"} = msg,
        socket
      ) do
    socket
    |> stream_insert(:system_objects, msg.system_object)
    |> noreply
  end

  def handle_info(
        %{event: :deleted_system_object, topic: "Durandal.Global.SystemObject"} = msg,
        socket
      ) do
    socket
    |> stream_delete(:system_objects, msg.system_object)
    |> noreply
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @spec get_system_objects(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_system_objects(%{assigns: assigns} = socket) do
    order_by =
      if assigns.search_term != "" do
        "Name (A-Z)"
      else
        "Newest first"
      end

    system_objects =
      Space.list_system_objects(
        where: [name_like: assigns.search_term],
        order_by: order_by,
        limit: 50
      )

    socket
    |> stream(:system_objects, system_objects, reset: true)
  end
end
