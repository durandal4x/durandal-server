defmodule DurandalWeb.Player.StationCommandListComponent do
  @moduledoc """
  <.live_component
    id={:commands}
    module={DurandalWeb.Player.StationCommandListComponent}
    station={@station}
    commands={@commands}
    station_lookup={@station_lookup}
    station_lookup={@station_lookup}
    system_object_lookup={@system_object_lookup}
  />


  <.live_component
    id={:commands}
    module={DurandalWeb.Player.StationCommandListComponent}
    commands={@commands}
    station_lookup={@station_lookup}
    station_lookup={@station_lookup}
    system_object_lookup={@system_object_lookup}
    station_module_type_lookup={@station_module_type_lookup}
    ship_type_lookup={@ship_type_lookup}
  >
    Post commands content here
  </.live_component>
  """
  use DurandalWeb, :live_component
  # alias Durandal.Player
  alias Durandal.Player.CommandLib

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.table id="commands-table" rows={@commands} table_class="table-sm table-hover">
        <:col :let={command} label="Type">
          {translate_internal_name(
            Map.get(@command_types, command.command_type, "N/A (#{command.command_type})")
          )}
        </:col>
        <:col :let={command} label="Progress">
          <div
            class="progress"
            role="progressbar"
            aria-label="Command progress"
            aria-valuenow={command.progress}
            aria-valuemin="0"
            aria-valuemax="100"
            style="height: 20px;"
          >
            <div
              class="progress-bar progress-bar-striped bg-info"
              style={"width: #{command.progress}%"}
            >
            </div>
            &nbsp;{command.progress}%
          </div>
        </:col>
        <:col :let={command} label="Contents">
          <span :if={command.command_type == "transfer_to_system_object"}>
            {gettext("Target")}: {@system_object_lookup[command.contents["system_object_id"]].name} &nbsp;&nbsp;&nbsp; {gettext(
              "Orbit distance"
            )}: {command.contents["orbit_distance"]}
          </span>
          <span :if={command.command_type == "transfer_to_station"}>
            {gettext("Target")}: {@station_lookup[command.contents["station_id"]].name}
          </span>
          <span :if={command.command_type == "build_ship"}>
            {gettext("Type")}: {@ship_type_lookup[command.contents["ship_type_id"]].name}
          </span>
          <span :if={command.command_type == "build_module"}>
            {gettext("Type")}: {@station_module_type_lookup[command.contents["module_type_id"]].name}
          </span>
        </:col>
        <:action :let={command}>
          <span
            class="btn btn-sm btn-info"
            phx-click="command-lower-order"
            phx-value-command_id={command.id}
          >
            <Fontawesome.icon icon="arrow-up" style="regular" />
          </span>
        </:action>
        <:action :let={command}>
          <span
            class="btn btn-sm btn-info"
            phx-click="command-higher-order"
            phx-value-command_id={command.id}
          >
            <Fontawesome.icon icon="arrow-down" style="regular" />
          </span>
        </:action>

        <:action :let={command}>
          <span
            class="btn btn-sm btn-warning"
            phx-click="cancel-command"
            phx-value-command_id={command.id}
          >
            <Fontawesome.icon icon="times" style="regular" /> {gettext("Cancel")}
          </span>
        </:action>
      </.table>
      <br />
      {if assigns[:inner_block], do: render_slot(@inner_block)}
    </div>
    """
  end

  @impl true
  def mount(socket) do
    form = to_form(%{}, as: "command")
    {:ok, assign(socket, form: form)}
  end

  @impl true
  def update(assigns, socket) do
    command_types =
      "station"
      |> CommandLib.command_types()
      |> Map.new(fn {a, b} -> {b, a} end)

    socket
    |> assign(assigns)
    |> assign(:command_types, command_types)
    |> ok
  end
end
