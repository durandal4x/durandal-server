defmodule DurandalWeb.Profile.SettingsLive do
  @moduledoc false
  use DurandalWeb, :live_view

  alias Durandal.Settings

  @impl true
  def mount(_, _session, socket) do
    socket =
      socket
      |> assign(:tab, nil)
      |> assign(:site_menu_active, "profile")
      |> assign(:show_descriptions, false)
      |> assign(:temp_value, nil)
      |> assign(:selected_key, nil)
      |> load_setting_types
      |> load_user_configs

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, _live_action, _params) do
    socket
    |> assign(:page_title, "Settings")
  end

  @impl true
  def handle_event("open-form", %{"key" => key}, %{assigns: assigns} = socket) do
    new_key =
      if assigns.selected_key == key do
        nil
      else
        key
      end

    current_value = Settings.get_user_setting_value(assigns.current_user.id, key)

    {:noreply,
     socket
     |> assign(:selected_key, new_key)
     |> assign(:temp_value, current_value)}
  end

  def handle_event(
        "reset-value",
        _,
        %{assigns: %{selected_key: key, current_user: user}} = socket
      ) do
    case Settings.get_user_setting(user.id, key) do
      nil ->
        :ok

      user_config ->
        Settings.delete_user_setting(user_config)
    end

    new_config_values = Map.put(socket.assigns.config_values, key, nil)

    {:noreply,
     socket
     |> assign(:config_values, new_config_values)
     |> assign(:selected_key, nil)
     |> assign(:temp_value, nil)}
  end

  def handle_event("set-" <> _, _, %{assigns: %{selected_key: nil}} = socket) do
    {:noreply, socket}
  end

  def handle_event("set-true", _, %{assigns: %{selected_key: key, current_user: user}} = socket) do
    new_value = "true"
    insert_or_update_setting(user.id, key, new_value)

    new_config_values = Map.put(socket.assigns.config_values, key, new_value)

    {:noreply,
     socket
     |> assign(:config_values, new_config_values)
     |> assign(:selected_key, nil)
     |> assign(:temp_value, nil)}
  end

  def handle_event("set-false", _, %{assigns: %{selected_key: key, current_user: user}} = socket) do
    new_value = "false"
    insert_or_update_setting(user.id, key, new_value)

    new_config_values = Map.put(socket.assigns.config_values, key, new_value)

    {:noreply,
     socket
     |> assign(:config_values, new_config_values)
     |> assign(:selected_key, nil)
     |> assign(:temp_value, nil)}
  end

  def handle_event(
        "set-to",
        %{"value" => new_value},
        %{assigns: %{selected_key: key, current_user: user}} = socket
      ) do
    insert_or_update_setting(user.id, key, new_value)

    new_config_values = Map.put(socket.assigns.config_values, key, new_value)

    {:noreply,
     socket
     |> assign(:config_values, new_config_values)
     |> assign(:selected_key, nil)
     |> assign(:temp_value, nil)}
  end

  def handle_event(_string, _event, socket) do
    {:noreply, socket}
  end

  defp insert_or_update_setting(user_id, key, value) do
    case Settings.get_user_setting(user_id, key) do
      nil ->
        {:ok, _setting} =
          Settings.create_user_setting(%{
            "user_id" => user_id,
            "key" => key,
            "value" => value
          })

        Settings.UserSettingLib.invalidate_user_setting_cache(user_id, key)

      user_setting ->
        {:ok, _setting} =
          Settings.update_user_setting(user_setting, %{
            "value" => value
          })

        Settings.UserSettingLib.invalidate_user_setting_cache(user_id, key)
    end
  end

  defp load_setting_types(socket) do
    config_types =
      Settings.list_user_setting_type_keys()
      |> Settings.list_user_setting_types()
      |> Enum.filter(fn type -> type.permissions != ["not-visible"] end)
      |> Enum.group_by(fn t -> t.section end)

    socket
    |> assign(:config_types, config_types)
  end

  defp load_user_configs(%{assigns: %{current_user: user}} = socket) do
    config_values =
      Settings.list_user_settings(
        where: [user_id: user.id],
        select: [:key, :value]
      )
      |> Map.new(fn %{key: key, value: value} -> {key, value} end)

    socket
    |> assign(:config_values, config_values)
  end

  # Allows us to convert a choices key into a displayed value
  def user_setting_display_value(type, nil) do
    user_setting_display_value(type, type.default) <> " (default)"
  end

  def user_setting_display_value(%{choices: choices} = _type, value) when not is_nil(choices) do
    choices
    |> Map.new(fn {a, b} -> {b, a} end)
    |> Map.get(value)
  end

  def user_setting_display_value(_, value), do: value
end
