defmodule DurandalWeb.Admin.Player.TeamMember.IndexLive do
  @moduledoc false
  use DurandalWeb, :live_view

  alias Durandal.Player

  @impl true
  def mount(%{"team_id" => team_id}, _session, socket) when is_connected?(socket) do
    # :ok = Durandal.subscribe(Game.team_member_global_topic())

    socket
    |> assign(:site_menu_active, "game")
    |> assign(:search_term, "")
    |> assign(:team_id, team_id)
    |> stream_configure(:team_members, dom_id: &"team_members-#{&1.team_id}-#{&1.user_id}")
    |> get_team_members
    |> ok
  end

  def mount(%{"team_id" => team_id}, _session, socket) do
    {:ok,
     socket
     |> assign(:team_id, team_id)
     |> stream_configure(:team_members, dom_id: &"team_members-#{&1.team_id}-#{&1.user_id}")
     |> stream(:team_members, [])
     |> assign(:site_menu_active, "game")}
  end

  @impl true
  def handle_event("update-search", %{"value" => search_term}, socket) do
    socket
    |> assign(:search_term, search_term)
    |> noreply
  end

  @impl true
  def handle_info(
        %{event: :created_team_member, topic: "Durandal.Global.TeamMember"} = msg,
        socket
      ) do
    socket
    |> stream_insert(:team_members, msg.team_member)
    |> noreply
  end

  def handle_info(
        %{event: :updated_team_member, topic: "Durandal.Global.TeamMember"} = msg,
        socket
      ) do
    socket
    |> stream_insert(:team_members, msg.team_member)
    |> noreply
  end

  def handle_info(
        %{event: :deleted_team_member, topic: "Durandal.Global.TeamMember"} = msg,
        socket
      ) do
    socket
    |> stream_delete(:team_members, msg.team_member)
    |> noreply
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @spec get_team_members(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_team_members(%{assigns: assigns} = socket) do
    order_by =
      if assigns.search_term != "" do
        "Name (A-Z)"
      else
        "Newest first"
      end

    team_members =
      Player.list_team_members(
        where: [name_like: assigns.search_term, team_id: assigns.team_id],
        preload: [:user],
        order_by: order_by,
        limit: assigns[:limit] || 50
      )

    team = Player.get_team!(assigns.team_id, preload: [:universe])

    socket
    |> assign(:team, team)
    |> assign(:universe, team.universe)
    |> stream(:team_members, team_members, reset: true)
  end
end
