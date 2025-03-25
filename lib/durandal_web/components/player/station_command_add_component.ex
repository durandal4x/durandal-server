defmodule DurandalWeb.Player.StationCommandAddComponent do
  @moduledoc """
  <.live_component
    id={:commands}
    module={DurandalWeb.Player.StationCommandAddComponent}

    subject={@station}
    team={@current_team}
    current_user={@current_user}
  />
  """
  use DurandalWeb, :live_component
  alias Durandal.{Player, Space, Types}
  alias Durandal.Player.CommandLib

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        id="quick_add_command-form"
      >
        <div class="row mb-4">
          <.input field={@form[:universe_id]} type="hidden" />
          <.input field={@form[:team_id]} type="hidden" />
          <.input field={@form[:user_id]} type="hidden" />
          <.input field={@form[:subject_id]} type="hidden" />
          <.input field={@form[:subject_type]} type="hidden" />

          <div class="col-md-2">
            <.input
              field={@form[:command_type]}
              type="select"
              options={@command_types}
              class="d-inline-block"
              label="Command:"
            />
          </div>
          <div class="col-md-8">
            <div :if={@command_type == "move_to_position"}>
              <.input
                field={@form[:contents]}
                type="in_map"
                key="position"
                actual_type="3dvector"
                label="Position: "
              />
            </div>
            <div :if={@command_type == "move_to_ship"}>
              <.input
                field={@form[:contents]}
                type="in_map"
                key="target"
                actual_type="select"
                label="Target: "
                options={@target_list}
              />
            </div>
            <div :if={@command_type == "move_to_system_object"}>
              <.input
                field={@form[:contents]}
                type="in_map"
                key="target"
                actual_type="select"
                label="Target: "
                options={@target_list}
              />
            </div>
            <div :if={@command_type == "orbit_system_object"}>
              <.input
                field={@form[:contents]}
                type="in_map"
                key="target"
                actual_type="select"
                label="Target: "
                options={@target_list}
              />
            </div>
            <div :if={@command_type == "move_to_station"}>
              <.input
                field={@form[:contents]}
                type="in_map"
                key="target"
                actual_type="select"
                label="Target: "
                options={@target_list}
              />
            </div>
            <div :if={@command_type == "build_module"}>
              <.input
                field={@form[:contents]}
                type="in_map"
                key="target"
                actual_type="select"
                label="Type: "
                options={@type_list}
              />
            </div>
            <div :if={@command_type == "build_ship"}>
              <.input
                field={@form[:contents]}
                type="in_map"
                key="target"
                actual_type="select"
                label="Type: "
                options={@type_list}
              />
            </div>
          </div>

          <div class="col-md-2">
            &nbsp;
            <button class="btn btn-primary btn-block" type="submit">
              <Fontawesome.icon icon="plus" style="regular" /> Add
            </button>
          </div>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{command: command} = assigns, socket) do
    changeset = Player.change_command(command)

    existing_members =
      Player.list_commands(where: [team_id: command.team_id], select: [:user_id])
      |> Enum.map(& &1.user_id)

    socket
    |> assign(assigns)
    |> assign(:command_types, CommandLib.command_types("station", "en-gb"))
    |> assign(:command_type, nil)
    |> assign(:existing_members, existing_members)
    |> assign_form(changeset)
    |> assign(:last_name_lookup, nil)
    |> assign(:target_list_type, nil)
    |> assign(:type_list, nil)
    |> assign(:type_list_type, nil)
    |> maybe_change_command_type()
    |> ok
  end

  # Command type might have been changed, if it has we want to update our
  # cache of relevant info regarding it (e.g. stations to target)
  defp maybe_change_command_type(%{assigns: assigns} = socket) do
    changeset = assigns.form.source

    new_value = Ecto.Changeset.get_field(changeset, :command_type)

    if new_value != assigns.command_type do
      socket
      |> assign(:command_module, CommandLib.get_command_module!("station$" <> new_value))
      |> do_change_command_type(new_value)
      |> assign(:command_type, new_value)
    else
      socket
    end
  end

  defp do_change_command_type(%{assigns: assigns} = socket, "move_to_position") do
    changeset =
      assigns.command
      |> Player.change_command(%{"contents" => %{"position" => [1, 2, 3]}})

    socket
    |> assign(:target_list, nil)
    |> assign(:target_list_type, nil)
    |> assign_form(changeset)
  end

  defp do_change_command_type(%{assigns: assigns} = socket, "move_to_system_object") do
    target_list =
      if assigns.target_list_type != "system_object" do
        get_system_object_dropdown(socket)
      else
        assigns.target_list
      end

    changeset =
      assigns.command
      |> Player.change_command(%{"contents" => %{"target" => nil}})

    socket
    |> assign(:target_list, target_list)
    |> assign(:target_list_type, "system_object")
    |> assign_form(changeset)
  end

  defp do_change_command_type(%{assigns: assigns} = socket, "move_to_ship") do
    target_list =
      if assigns.target_list_type != "ship" do
        get_ship_dropdown(socket)
      else
        assigns.target_list
      end

    changeset =
      assigns.command
      |> Player.change_command(%{"contents" => %{"target" => nil}})

    socket
    |> assign(:target_list, target_list)
    |> assign(:target_list_type, "ship")
    |> assign_form(changeset)
  end

  defp do_change_command_type(%{assigns: assigns} = socket, "orbit_system_object") do
    target_list =
      if assigns.target_list_type != "system_object" do
        get_system_object_dropdown(socket)
      else
        assigns.target_list
      end

    changeset =
      assigns.command
      |> Player.change_command(%{"contents" => %{"target" => nil}})

    socket
    |> assign(:target_list, target_list)
    |> assign(:target_list_type, "system_object")
    |> assign_form(changeset)
  end

  defp do_change_command_type(%{assigns: assigns} = socket, "move_to_station") do
    target_list =
      if assigns.target_list_type != "station" do
        get_station_dropdown(socket)
      else
        assigns.target_list
      end

    changeset =
      assigns.command
      |> Player.change_command(%{"contents" => %{"target" => nil}})

    socket
    |> assign(:target_list, target_list)
    |> assign(:target_list_type, "station")
    |> assign_form(changeset)
  end

  defp do_change_command_type(%{assigns: assigns} = socket, "build_module") do
    type_list =
      if assigns.type_list_type != "station_module" do
        get_station_module_type_dropdown(socket)
      else
        assigns.type_list
      end

    changeset =
      assigns.command
      |> Player.change_command(%{"contents" => %{"type" => ""}})

    socket
    |> assign(:type_list, type_list)
    |> assign(:type_list_type, "station_module")
    |> assign_form(changeset)
  end

  defp do_change_command_type(%{assigns: assigns} = socket, "build_ship") do
    type_list =
      if assigns.type_list_type != "ship" do
        get_ship_type_dropdown(socket)
      else
        assigns.type_list
      end

    changeset =
      assigns.command
      |> Player.change_command(%{"contents" => %{"type" => ""}})

    socket
    |> assign(:type_list, type_list)
    |> assign(:type_list_type, "ship")
    |> assign_form(changeset)
  end

  @impl true
  def handle_event("validate", %{"command" => command_params}, socket) do
    parsed_contents =
      command_params["contents"]
      |> socket.assigns.command_module.parse()

    command_params = Map.put(command_params, "contents", parsed_contents)

    changeset =
      socket.assigns.command
      |> Player.change_command(command_params)
      |> Map.put(:action, :validate)

    notify_parent({:updated_changeset, changeset})

    socket
    |> assign_form(changeset)
    |> maybe_change_command_type
    |> noreply
  end

  def handle_event("save", %{"command" => command_params}, socket) do
    parsed_contents =
      command_params["contents"]
      |> socket.assigns.command_module.parse()

    ordering =
      Durandal.Player.CommandQueries.next_ordering_for_subject(command_params["subject_id"])

    command_params =
      Map.merge(command_params, %{
        "contents" => parsed_contents,
        "ordering" => ordering
      })

    if socket.assigns.form.source.valid? do
      case Player.create_command(command_params) do
        {:ok, command} ->
          notify_parent({:saved, command})

          socket
          |> noreply

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign_form(socket, changeset)}
      end
    else
      socket
      |> noreply
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp get_ship_dropdown(socket) do
    Space.list_ships(
      where: [
        system_id: socket.assigns.subject.system_id,
        id_not: socket.assigns.subject.id
      ],
      order_by: "Name (A-Z)",
      select: [:id, :name]
    )
    |> Enum.map(fn row -> {row.name, row.id} end)
  end

  defp get_station_dropdown(socket) do
    Space.list_stations(
      where: [
        system_id: socket.assigns.subject.system_id,
        id_not: socket.assigns.subject.id
      ],
      order_by: "Name (A-Z)",
      select: [:id, :name]
    )
    |> Enum.map(fn row -> {row.name, row.id} end)
  end

  defp get_system_object_dropdown(socket) do
    Space.list_system_objects(
      where: [system_id: socket.assigns.subject.system_id],
      order_by: "Name (A-Z)",
      select: [:id, :name]
    )
    |> Enum.map(fn row -> {row.name, row.id} end)
  end

  def get_ship_type_dropdown(socket) do
    Types.list_ship_types(
      where: [universe_id: socket.assigns.subject.universe_id],
      order_by: "Name (A-Z)",
      select: [:id, :name]
    )
    |> Enum.map(fn row -> {row.name, row.id} end)
  end

  def get_station_module_type_dropdown(socket) do
    Types.list_station_module_types(
      where: [universe_id: socket.assigns.subject.universe_id],
      order_by: "Name (A-Z)",
      select: [:id, :name]
    )
    |> Enum.map(fn row -> {row.name, row.id} end)
  end
end
