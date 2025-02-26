defmodule DurandalWeb.Admin.Player.TeamMember.ShowLive do
  @moduledoc false
  use DurandalWeb, :live_view
  alias Durandal.{Game, Player}

  @impl true
  def mount(%{"team_id" => team_id, "user_id" => user_id}, _session, socket)
      when is_connected?(socket) do
    socket =
      socket
      |> assign(:site_menu_active, "game")
      |> assign(:team_id, team_id)
      |> assign(:user_id, user_id)
      |> get_team_member()

    if socket.assigns.team_member do
      # :ok = Durandal.subscribe(Player.team_member_topic(team_id))

      {:ok, socket}
    else
      {:ok, redirect(socket, to: ~p"/admin/games")}
    end
  end

  def mount(_params, _session, socket) do
    socket
    |> assign(:site_menu_active, "game")
    |> assign(:team_id, nil)
    |> assign(:team_member, nil)
    |> stream(:team_member_members, [])
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

  defp apply_action(socket, :delete, %{"team_id" => team_id, "user_id" => user_id}) do
    Durandal.Player.DeleteTeamMemberTask.perform(team_id, user_id)

    socket
    |> redirect(to: ~p"/admin/teams/#{team_id}")
    |> put_flash(:info, "TeamMember deleted")
  end

  defp apply_action(socket, _, _params) do
    socket
    |> assign(:edit_mode, false)
  end

  @impl true
  def handle_event("delete", _params, socket) do
    Durandal.Player.DeleteTeamMemberTask.perform(socket.assigns.team_id, socket.assigns.user_id)

    socket
    |> redirect(to: ~p"/admin/teams/#{socket.assigns.team_id}")
    |> put_flash(:info, "TeamMember deleted")
    |> noreply
  end

  @impl true
  # TeamMember updates
  def handle_info(
        %{event: :updated_team_member, topic: "Durandal.Player.TeamMember:" <> _} = msg,
        socket
      ) do
    socket
    |> assign(:team_member, msg.team_member)
    |> noreply
  end

  def handle_info(
        %{event: :deleted_team_member, topic: "Durandal.Player.TeamMember" <> _} = _msg,
        socket
      ) do
    socket
    |> redirect(to: ~p"/admin/team_members")
    |> noreply
  end

  def handle_info(
        {DurandalWeb.Player.TeamMemberFormComponent, {:updated_changeset, %{changes: _changes}}},
        socket
      ) do
    {:noreply, socket}
  end

  @spec get_team_member(Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp get_team_member(%{assigns: %{team_id: team_id, user_id: user_id}} = socket) do
    team_member = Player.get_team_member!(team_id, user_id, preload: [:team, :user])
    universe = Game.get_universe!(team_member.team.universe_id)

    socket
    |> assign(:team_member, team_member)
    |> assign(:universe, universe)
  end
end
