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
          {Map.get(@command_types, command.command_type, "N/A (#{command.command_type})")}
        </:col>
        <:col :let={command} label="Contents">
          <span :if={command.command_type == "move_to_position"}>
            Target: <.vector_string value={command.contents["position"]} />
          </span>
          <span :if={command.command_type == "move_to_system_object"}>
            Target: {@system_object_lookup[command.contents["target"]].name}
          </span>
          <span :if={command.command_type == "orbit_system_object"}>
            Target: {@system_object_lookup[command.contents["target"]].name}
          </span>
          <span :if={command.command_type == "move_to_station"}>
            Target: {@station_lookup[command.contents["target"]].name}
          </span>
          <span :if={command.command_type == "move_to_station"}>
            Target: {@station_lookup[command.contents["target"]].name}
          </span>
          <span :if={command.command_type == "build_ship"}>
            Type: {@ship_type_lookup[command.contents["type"]].name}
          </span>
          <span :if={command.command_type == "build_module"}>
            Type: {@station_module_type_lookup[command.contents["type"]].name}
          </span>
        </:col>
        <:action :let={command}>
          <span
            class="btn btn-sm btn-warning"
            phx-click="cancel-command"
            phx-value-command_id={command.id}
          >
            <Fontawesome.icon icon="times" style="regular" /> Cancel
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
      |> CommandLib.command_types("en-gb")
      |> Map.new(fn {a, b} -> {b, a} end)

    socket
    |> assign(assigns)
    |> assign(:command_types, command_types)
    |> ok
  end
end
