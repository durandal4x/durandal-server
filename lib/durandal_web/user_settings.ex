defmodule DurandalWeb.UserSettings do
  # use DurandalWeb, :verified_routes

  # import Plug.Conn
  # import Phoenix.Controller
  import Phoenix.Component, only: [assign: 3]

  alias Durandal.{Game, Player, Settings}

  @keys ~w(current_team_id current_universe_id timezone language)

  def on_mount(:load_user_configs, _params, _session, socket) do
    {:cont, load_user_configs(socket)}
  end

  defp load_user_configs(%{assigns: %{current_user: nil}} = socket) do
    socket
    |> assign(:current_universe, nil)
    |> assign(:current_team, nil)
  end
  defp load_user_configs(%{assigns: %{current_user: current_user}} = socket) do
    socket
    |> assign(:user_settings, Settings.get_multiple_user_setting_values(current_user.id, @keys))
    |> maybe_load_universe
    |> maybe_load_team
  end

  defp maybe_load_universe(%{assigns: %{user_settings: %{"current_universe_id" => nil}}} = socket) do
    socket
    |> assign(:current_universe, nil)
    |> assign(:current_team, nil)
  end
  defp maybe_load_universe(%{assigns: %{user_settings: settings}} = socket) do
    socket
    |> assign(:current_universe, Game.get_universe_by_id(settings["current_universe_id"]))
  end

  defp maybe_load_team(%{assigns: %{user_settings: %{team_id: nil}}} = socket) do
    socket
    |> assign(:current_team, nil)
  end
  defp maybe_load_team(%{assigns: %{user_settings: settings}} = socket) do
    team_member = Player.get_team_member_by_id(settings["current_team_id"], socket.assigns.current_user.id)

    socket
    |> assign(:current_team, Player.get_team_by_id(settings["current_team_id"]))
    |> assign(:current_team_member, team_member)
  end

  @doc """
  If the key given is one of the keys we use then we want to invalidate the entire
  object to prevent a stale component.
  """
  def maybe_invalidate_plug_cache(user_id, key) do
    if Enum.member?(@keys, key) do
      Durandal.Settings.UserSettingLib.invalidate_multi_cache(user_id, @keys)
    end
  end

  def refresh_settings(socket) do
    socket
    |> load_user_configs
  end
end
