defmodule DurandalWeb.Player.ShipCommandAddComponent do
  @moduledoc """
  <.live_component
    id={:commands}
    module={DurandalWeb.Player.ShipCommandAddComponent}

    subject={@ship}
    team={@current_team}
    current_user={@current_user}
  />
  """
  use DurandalWeb, :live_component
  alias Durandal.{Player, Space}
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
            <.input field={@form[:command_type]} type="select" options={@command_types} class="d-inline-block" label="Command:" />
          </div>
          <div class="col-md-8">
            <div :if={@command_type == "move_to_position"}>
              <.input field={@form[:contents]} type="in_map" key="position" actual_type="3dvector" label="Position: " />
            </div>
            <div :if={@command_type == "move_to_object"}>
              <.input field={@form[:contents]} type="in_map" key="target" actual_type="select" label="Target: " options={@target_list} />
            </div>
            <div :if={@command_type == "orbit_object"}>
              <.input field={@form[:contents]} type="in_map" key="target" actual_type="select" label="Target: " options={@target_list} />
            </div>
            <div :if={@command_type == "move_to_station"}>
              <.input field={@form[:contents]} type="in_map" key="target" actual_type="select" label="Target: " options={@target_list} />

            </div>
            <div :if={@command_type == "move_to_ship"}>
              <.input field={@form[:contents]} type="in_map" key="target" actual_type="select" label="Target: " options={@target_list} />
            </div>
            <div :if={@command_type == "dock"}>
              <.input field={@form[:contents]} type="in_map" key="target" actual_type="select" label="Target: " options={@target_list} />
            </div>
          </div>

          <div class="col-md-2">
            <button class="btn btn-primary btn-block" type="submit">
              <Fontawesome.icon icon="plus" style="regular" />
            </button>
          </div>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{command: command} = assigns, socket) do
    assigns = assigns
      |> update_assign(:command_types)

    changeset = Player.change_command(command)

    existing_members =
      Player.list_commands(where: [team_id: command.team_id], select: [:user_id])
      |> Enum.map(& &1.user_id)

    socket
    |> assign(assigns)
    |> assign(:existing_members, existing_members)
    |> assign_form(changeset)
    |> assign(:last_name_lookup, nil)
    |> assign(:target_list_type, nil)
    |> maybe_change_command_type()
    |> ok
  end

  defp update_assign(%{command: %{subject_type: subject_type}} = assigns, :command_types) do
    Map.merge(assigns, %{
      command_types: CommandLib.command_types(subject_type),
      command_type: nil
    })
  end

  defp update_assign(assigns, _), do: assigns

  # Command type might have been changed, if it has we want to update our
  # cache of relevant info regarding it (e.g. ships to target)
  defp maybe_change_command_type(%{assigns: assigns} = socket) do
    changeset = assigns.form.source

    new_value = Ecto.Changeset.get_field(changeset, :command_type)

    if new_value != assigns.command_type do
      socket
      |> do_change_command_type(new_value)
      |> assign(:command_type, new_value)
    else
      socket
    end
  end

  defp do_change_command_type(%{assigns: assigns} = socket, "move_to_position") do
    changeset =
      assigns.command
      |> Player.change_command(%{"contents" => %{"position" => [1,2,3]}})

    socket
    |> assign(:target_list, nil)
    |> assign(:target_list_type, nil)
    |> assign_form(changeset)
  end

  defp do_change_command_type(%{assigns: assigns} = socket, "move_to_object") do
    target_list = if assigns.target_list_type != "system_object" do
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

  defp do_change_command_type(%{assigns: assigns} = socket, "orbit_object") do
    target_list = if assigns.target_list_type != "system_object" do
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
    target_list = if assigns.target_list_type != "station" do
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

  defp do_change_command_type(%{assigns: assigns} = socket, "move_to_ship") do
    target_list = if assigns.target_list_type != "ship" do
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

  defp do_change_command_type(%{assigns: assigns} = socket, "dock") do
    target_list = if assigns.target_list_type != "station" do
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


  @impl true
  def handle_event("validate", %{"command" => command_params}, socket) do
    command_params =
      convert_params(command_params)
      # |> maybe_lookup_user_name(socket.assigns.last_name_lookup)

    changeset =
      socket.assigns.command
      |> Player.change_command(command_params)
      |> Map.put(:action, :validate)
      # |> maybe_error_name(socket.assigns.existing_members)

    notify_parent({:updated_changeset, changeset})

    socket
    |> assign_form(changeset)
    |> maybe_change_command_type
    |> noreply
  end

  def handle_event("save", %{"command" => command_params}, socket) do
    command_params = convert_params(command_params)

    if socket.assigns.form.source.valid? do
      case Player.create_command(command_params) do
        {:ok, command} ->
          notify_parent({:saved, command})

          socket
          |> put_flash(:info, "TeamMember created successfully")
          |> redirect(to: socket.assigns.patch)
          |> noreply

        {:error, %Ecto.Changeset{} = changeset} ->
          changeset = changeset
          # |> maybe_error_name(socket.assigns.existing_members)

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

  defp convert_params(params) do
    params
  end

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

  defp get_system_object_dropdown(socket) do
    Space.list_system_objects(
      where: [system_id: socket.assigns.subject.system_id],
      order_by: "Name (A-Z)",
      select: [:id, :name]
    )
    |> Enum.map(fn row -> {row.name, row.id} end)
  end

  defp get_station_dropdown(socket) do
    Space.list_stations(
      where: [system_id: socket.assigns.subject.system_id],
      order_by: "Name (A-Z)",
      select: [:id, :name]
    )
    |> Enum.map(fn row -> {row.name, row.id} end)
  end
end
