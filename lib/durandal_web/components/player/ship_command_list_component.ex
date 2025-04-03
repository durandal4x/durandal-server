defmodule DurandalWeb.Player.ShipCommandListComponent do
  @moduledoc """
  <.live_component
    id={:commands}
    module={DurandalWeb.Player.ShipCommandListComponent}
    ship={@ship}
    commands={@commands}
    ship_lookup={@ship_lookup}
    station_lookup={@station_lookup}
    system_object_lookup={@system_object_lookup}
  />

  <.live_component
    id={:commands}
    module={DurandalWeb.Player.ShipCommandListComponent}
    commands={@commands}
    ship_lookup={@ship_lookup}
    station_lookup={@station_lookup}
    system_object_lookup={@system_object_lookup}
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
        <:col :let={command} label="Contents">
          <span :if={command.command_type == "move_to_position"}>
            {gettext("Target")}: <.vector_string value={command.contents["position"]} />
          </span>
          <span :if={command.command_type == "move_to_system_object"}>
            {gettext("Target")}: {@system_object_lookup[command.contents["target"]].name}
          </span>
          <span :if={command.command_type == "orbit_system_object"}>
            {gettext("Target")}: {@system_object_lookup[command.contents["target"]].name}
          </span>
          <span :if={command.command_type == "move_to_station"}>
            {gettext("Target")}: {@station_lookup[command.contents["target"]].name}
          </span>
          <span :if={command.command_type == "move_to_ship"}>
            {gettext("Target")}: {@ship_lookup[command.contents["target"]].name}
          </span>
          <span :if={command.command_type == "dock_at_station"}>
            {gettext("Target")}: {@station_lookup[command.contents["station_id"]].name}
          </span>
        </:col>
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
      "ship"
      |> CommandLib.command_types()
      |> Map.new(fn {a, b} -> {b, a} end)

    socket
    |> assign(assigns)
    |> assign(:command_types, command_types)
    |> ok
  end
end
