defmodule DurandalWeb.Types.SystemObjectTypeFormComponent do
  @moduledoc false
  use DurandalWeb, :live_component
  # import Durandal.Helper.ColourHelper, only: [rgba_css: 2]

  alias Durandal.Types

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h3>
        {@title}
      </h3>

      <.form
        for={@form}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        id="system_object_type-form"
      >
        <div class="row mb-4">
          <%!-- Core properties --%>
          <div class="col-md-12 col-lg-6">
            <label for="system_object_type_name" class="control-label">Name:</label>
            <.input field={@form[:name]} type="text" autofocus="autofocus" phx-debounce="100" />
            <br />
          </div>

          <div :if={Ecto.assoc_loaded?(@system_object_type.universe)} class="col-md-12 col-lg-6">
            <label for="system_object_type_name" class="control-label">Universe:</label>
            <.input
              value={@system_object_type.universe.name}
              name="system_object_type_universe"
              type="text"
              disabled="disabled"
            />
            <br />
          </div>
        </div>

        <%= if @system_object_type.id do %>
          <div class="row">
            <div class="col">
              <a
                href={~p"/admin/system_object_types/#{@system_object_type.id}"}
                class="btn btn-secondary btn-block"
              >
                Cancel
              </a>
            </div>
            <div class="col">
              <button class="btn btn-primary btn-block" type="submit">
                Update system object type
              </button>
            </div>
          </div>
        <% else %>
          <div class="row">
            <div class="col">
              <a href={~p"/admin/games"} class="btn btn-secondary btn-block">
                Cancel
              </a>
            </div>
            <div class="col">
              <button class="btn btn-primary btn-block" type="submit">
                Create system object type
              </button>
            </div>
          </div>
        <% end %>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{system_object_type: system_object_type} = assigns, socket) do
    changeset = Types.change_system_object_type(system_object_type)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"system_object_type" => system_object_type_params}, socket) do
    system_object_type_params = convert_params(system_object_type_params)

    changeset =
      socket.assigns.system_object_type
      |> Types.change_system_object_type(system_object_type_params)
      |> Map.put(:action, :validate)

    notify_parent({:updated_changeset, changeset})

    {:noreply,
     socket
     |> assign_form(changeset)}
  end

  def handle_event("save", %{"system_object_type" => system_object_type_params}, socket) do
    system_object_type_params = convert_params(system_object_type_params)

    save_system_object_type(socket, socket.assigns.action, system_object_type_params)
  end

  defp save_system_object_type(socket, :edit, system_object_type_params) do
    case Types.update_system_object_type(
           socket.assigns.system_object_type,
           system_object_type_params
         ) do
      {:ok, system_object_type} ->
        notify_parent({:saved, system_object_type})

        {:noreply,
         socket
         |> put_flash(:info, "Team updated successfully")
         |> redirect(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_system_object_type(socket, :new, system_object_type_params) do
    case Types.create_system_object_type(system_object_type_params) do
      {:ok, system_object_type} ->
        notify_parent({:saved, system_object_type})

        {:noreply,
         socket
         |> put_flash(:info, "Team created successfully")
         |> redirect(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp convert_params(params) do
    params
  end
end
