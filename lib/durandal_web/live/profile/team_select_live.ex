defmodule DurandalWeb.Profile.TeamSelectLive do
  use DurandalWeb, :live_view

  @impl true
  def mount(_params, _session, socket) when is_connected?(socket) do
    memberships = Durandal.Player.TeamMemberQueries.list_all_enabled_team_memberships(socket.assigns.current_user.id)

    # If this is the users first time accessing the page then it will take two clicks to set the selected_team, we check for this here and insert an empty row accordingly
    s = Durandal.Settings.get_user_setting(socket.assigns.current_user.id, "current_universe")
    IO.puts ""
    IO.inspect s, label: "#{__MODULE__}:#{__ENV__.line}"
    IO.puts ""

    socket
    |> assign(:site_menu_active, "home")
    |> assign(:memberships, memberships)
    |> ok
  end

  def mount(_params, _session, socket) do
    socket
    |> assign(:site_menu_active, "home")
    |> assign(:memberships, [])
    |> ok
  end

  @impl true
  def handle_event("select-team", %{"team_id" => team_id}, %{assigns: %{current_user: current_user}} = socket) do
    Durandal.Player.TeamMemberLib.update_selected_team(current_user.id, team_id)

    socket
    |> DurandalWeb.UserSettings.refresh_settings
    |> noreply
  end
end
