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
  alias Durandal.{Player, Space, Resources}
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
              label={gettext("Command")}
            />
          </div>
          <div class="col-md-8">
            <%!-- Moving relative to System objects --%>
            <div :if={@command_type == "transfer_to_system_object"}>
              <.input
                field={@form[:contents]}
                type="in_map"
                key="system_object_id"
                actual_type="select"
                label={gettext("System object")}
                options={@target_list}
              />
              <br />

              <.input
                field={@form[:contents]}
                type="in_map"
                key="orbit_distance"
                actual_type="number"
                label={gettext("Orbit distance")}
              />
            </div>

            <%!-- Moving relative to Stations --%>
            <div :if={@command_type == "transfer_to_station"}>
              <.input
                field={@form[:contents]}
                type="in_map"
                key="station_id"
                actual_type="select"
                label={gettext("Station")}
                options={@target_list}
              />
            </div>
            <div :if={@command_type == "dock_at_station"}>
              <.input
                field={@form[:contents]}
                type="in_map"
                key="station_id"
                actual_type="select"
                label={gettext("Station")}
                options={@target_list}
              />
            </div>

            <%!-- Cargo --%>
            <div :if={@command_type == "unload_cargo"}>
              <div :if={@subject.docked_with_id == nil}>
                Need to dock to unload cargo
              </div>
              <div :if={@subject.docked_with_id != nil}>
                <.table
                  id="unload-simple-resources-table"
                  rows={@cargo}
                  table_class="table-sm table-hover"
                >
                  <:col :let={cargo} label="Simple">{cargo.type.name}</:col>
                  <:col :let={cargo} label="Available">{format_number(cargo.quantity)}</:col>
                  <:col :let={cargo} label="Unload amount">
                    <.input
                      field={@form[:contents]}
                      type="in_map"
                      key={["form_resources", cargo.type_id]}
                      actual_type="number"
                    />
                  </:col>
                </.table>
              </div>
            </div>
            <div :if={@command_type == "load_cargo"}>
              <div :if={@subject.docked_with_id == nil}>
                Need to dock to load cargo
              </div>
              <div :if={@subject.docked_with_id != nil}>
                <.table
                  id="load-simple-resources-table"
                  rows={@cargo}
                  table_class="table-sm table-hover"
                >
                  <:col :let={cargo} label="Simple">{cargo.type.name}</:col>
                  <:col :let={cargo} label="Available">{format_number(cargo.quantity)}</:col>
                  <:col :let={cargo} label="Load amount">
                    <.input
                      field={@form[:contents]}
                      type="in_map"
                      key={["form_resources", cargo.type_id]}
                      actual_type="number"
                    />
                  </:col>
                </.table>
              </div>
            </div>
          </div>

          <div class="col-md-2">
            &nbsp;
            <button class="btn btn-primary btn-block" type="submit">
              <Fontawesome.icon icon="plus" style="regular" /> {gettext("Add")}
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
    command_types = CommandLib.command_types("ship")

    changeset =
      if Ecto.Changeset.fetch_field!(changeset, :command_type) != nil do
        changeset
      else
        default_type =
          command_types
          |> Map.values()
          |> Enum.sort()
          |> hd

        Ecto.Changeset.put_change(changeset, :command_type, default_type)
      end

    existing_members =
      Player.list_commands(where: [team_id: command.team_id], select: [:user_id])
      |> Enum.map(& &1.user_id)

    socket
    |> assign(assigns)
    |> assign(:command_types, command_types)
    |> assign(:command_type, nil)
    |> assign(:existing_members, existing_members)
    |> assign_form(changeset)
    |> assign(:last_name_lookup, nil)
    |> assign(:target_list_type, nil)
    |> assign(:ship_cargo, nil)
    |> assign(:station_cargo, nil)
    |> maybe_change_command_type()
    |> ok
  end

  # Command type might have been changed, if it has we want to update our
  # cache of relevant info regarding it (e.g. ships to target)
  defp maybe_change_command_type(%{assigns: assigns} = socket) do
    changeset = assigns.form.source

    new_value = Ecto.Changeset.get_field(changeset, :command_type)

    if new_value != assigns.command_type do
      socket
      |> assign(:command_module, CommandLib.get_command_module!("ship$" <> new_value))
      |> assign(:command_type, new_value)
      |> do_change_command_type(new_value)
    else
      socket
    end
  end

  defp do_change_command_type(%{assigns: assigns} = socket, "transfer_to_system_object") do
    target_list =
      if assigns.target_list_type != "system_object" do
        get_system_object_dropdown(socket)
      else
        assigns.target_list
      end

    changeset =
      assigns.command
      |> Player.change_command(%{
        "contents" => %{
          "system_object_id" => nil,
          "orbit_distance" => 1000
        }
      })

    socket
    |> assign(:target_list, target_list)
    |> assign(:target_list_type, "system_object")
    |> assign_form(changeset)
  end

  defp do_change_command_type(%{assigns: assigns} = socket, "dock_at_station") do
    target_list =
      if assigns.target_list_type != "station" do
        get_station_dropdown(socket)
      else
        assigns.target_list
      end

    changeset =
      assigns.command
      |> Player.change_command(%{"contents" => %{"station_id" => nil}})

    socket
    |> assign(:target_list, target_list)
    |> assign(:target_list_type, "station")
    |> assign_form(changeset)
  end

  defp do_change_command_type(%{assigns: assigns} = socket, "undock_from_station") do
    changeset =
      assigns.command
      |> Player.change_command(%{"contents" => %{}})

    socket
    |> assign_form(changeset)
  end

  defp do_change_command_type(%{assigns: assigns} = socket, "transfer_to_station") do
    target_list =
      if assigns.target_list_type != "station" do
        get_station_dropdown(socket)
      else
        assigns.target_list
      end

    changeset =
      assigns.command
      |> Player.change_command(%{"contents" => %{"station_id" => nil}})

    socket
    |> assign(:target_list, target_list)
    |> assign(:target_list_type, "station")
    |> assign_form(changeset)
  end

  defp do_change_command_type(
         %{assigns: %{subject: %{docked_with_id: nil}}} = socket,
         "load_cargo"
       ) do
    socket
  end

  defp do_change_command_type(
         %{assigns: %{subject: %{docked_with_id: station_id}} = assigns} = socket,
         "load_cargo"
       ) do
    cargo =
      Space.list_station_modules(
        where: [station_id: station_id],
        preload: [:cargo]
      )
      |> Enum.map(&(&1.simple_cargo ++ &1.composite_cargo))
      |> Resources.combine_instances_by_type()
      |> Enum.sort_by(fn i -> i.type.name end, &<=/2)

    empty_resources =
      cargo
      |> Map.new(fn cargo -> {cargo.type_id, 0} end)

    changeset =
      assigns.command
      |> Player.change_command(%{
        "contents" => %{
          "form_resources" => empty_resources
        }
      })

    socket
    |> assign(:cargo, cargo)
    |> assign_form(changeset)
  end

  defp do_change_command_type(
         %{assigns: %{subject: %{docked_with_id: nil}}} = socket,
         "unload_cargo"
       ) do
    socket
  end

  defp do_change_command_type(%{assigns: assigns} = socket, "unload_cargo") do
    ship =
      Space.get_ship(assigns.subject.id,
        preload: [:cargo]
      )

    cargo =
      (ship.simple_cargo ++ ship.composite_cargo)
      |> Resources.combine_instances_by_type()
      |> Enum.sort_by(fn i -> i.type.name end, &<=/2)

    empty_resources =
      cargo
      |> Map.new(fn cargo -> {cargo.type_id, 0} end)

    changeset =
      assigns.command
      |> Player.change_command(%{
        "contents" => %{
          "form_resources" => empty_resources
        }
      })

    socket
    |> assign(:cargo, cargo)
    |> assign_form(changeset)
  end

  defp do_change_command_type(%{assigns: _assigns} = socket, command_type) do
    raise "No handler for command type of #{command_type}"
    socket
  end

  @impl true
  def handle_event("validate", %{"command" => command_params}, socket) do
    parsed_contents =
      if socket.assigns[:command_module] do
        command_params["contents"]
        |> parse_from_form(socket.assigns.command_type)
        |> socket.assigns.command_module.parse()
      else
        command_params["contents"]
      end

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
      |> parse_from_form(socket.assigns.command_type)
      |> socket.assigns.command_module.parse()

    ordering =
      Durandal.Player.CommandQueries.next_ordering_for_subject(command_params["subject_id"])

    command_params =
      Map.merge(command_params, %{
        "contents" => parsed_contents,
        "ordering" => ordering
      })

    # if socket.assigns.form.source.valid? do
    case Player.create_command(command_params) do
      {:ok, command} ->
        notify_parent({:saved, command})

        socket
        |> noreply

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

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

  defp parse_from_form(params, "unload_cargo") do
    new_resources =
      params["form_resources"]
      |> Enum.map(fn {k, v} ->
        v =
          case v do
            "" -> 0
            _ -> String.to_integer(v)
          end

        [k, v]
      end)

    Map.put(params, "resources", new_resources)
  end

  defp parse_from_form(params, "load_cargo") do
    new_resources =
      params["form_resources"]
      |> Enum.map(fn {k, v} ->
        v =
          case v do
            "" -> 0
            _ -> String.to_integer(v)
          end

        [k, v]
      end)

    Map.put(params, "resources", new_resources)
  end

  defp parse_from_form(params, _command_type), do: params
end
