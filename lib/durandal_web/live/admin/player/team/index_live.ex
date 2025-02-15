defmodule DurandalWeb.Admin.Player.Team.IndexLive do
  @moduledoc false
  use DurandalWeb, :live_view

  alias Durandal.Player

  @impl true
  def mount(_params, _session, socket) when is_connected?(socket) do
    # :ok = Durandal.subscribe(Game.team_global_topic())

    socket
    |> assign(:site_menu_active, "game")
    |> assign(:search_term, "")
    |> get_query_opts
    |> ok
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:query_opts, nil)
     |> assign(:site_menu_active, "game")}
  end

  @impl true
  def handle_event("update-search", %{"value" => search_term}, socket) do
    socket
    |> assign(:search_term, search_term)
    |> get_query_opts
    |> noreply
  end

  @impl true
  def handle_info(%{event: :created_team, topic: "Durandal.Global.Team"} = msg, socket) do
    socket
    |> stream_insert(:teams, msg.team)
    |> noreply
  end

  def handle_info(%{event: :updated_team, topic: "Durandal.Global.Team"} = msg, socket) do
    socket
    |> stream_insert(:teams, msg.team)
    |> noreply
  end

  def handle_info(%{event: :deleted_team, topic: "Durandal.Global.Team"} = msg, socket) do
    socket
    |> stream_delete(:teams, msg.team)
    |> noreply
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @spec get_query_opts(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_query_opts(%{assigns: assigns} = socket) do
    order_by =
      if assigns.search_term != "" do
        "Name (A-Z)"
      else
        "Newest first"
      end

    query_opts = [
      where: [name_like: assigns.search_term],
      order_by: order_by,
      limit: assigns[:limit] || 50
    ]

    socket
    |> assign(:query_opts, query_opts)
  end

  # @spec get_teams(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  # defp get_teams(%{assigns: assigns} = socket) do
  #   query_opts =

  #   teams =
  #     Player.list_teams(query_opts)

  #   socket
  #   |> assign(:query_opts, query_opts)
  #   |> stream(:teams, teams, reset: true)
  # end
end
