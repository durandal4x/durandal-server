defmodule DurandalWeb.Space.SystemObjectFormComponent do
  @moduledoc false
  use DurandalWeb, :live_component

  alias Durandal.Space

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
        id="system_object-form"
      >
        <div class="row mb-4">
          <%!-- Core properties --%>
          <div class="col-md-12 col-lg-6">
            <label for="system_object_name" class="control-label">Name:</label>
            <.input field={@form[:name]} type="text" autofocus="autofocus" phx-debounce="100" />
            <br />

            <label for="system_object_type_id" class="control-label">Type:</label>
            <.input field={@form[:type_id]} type="select" options={@type_list} phx-debounce="100" />
            <br />

            <label for="system_object_system_id" class="control-label">System:</label>
            <.input field={@form[:system_id]} type="select" options={@system_list} phx-debounce="100" />
            <br />
          </div>

          <div class="col-md-12 col-lg-6">
            <label for="system_object_position" class="control-label">Position:</label>
            <.input field={@form[:position]} type="3dvector" phx-debounce="100" />
            <br />

            <label for="system_object_velocity" class="control-label">Velocity:</label>
            <.input field={@form[:velocity]} type="3dvector" phx-debounce="100" />
            <br />
          </div>
        </div>

        <%= if @system_object.id do %>
          <div class="row">
            <div class="col">
              <a
                href={~p"/admin/system_objects/#{@system_object.id}"}
                class="btn btn-secondary btn-block"
              >
                Cancel
              </a>
            </div>
            <div class="col">
              <button class="btn btn-primary btn-block" type="submit">Update system_object</button>
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
              <button class="btn btn-primary btn-block" type="submit">Create system_object</button>
            </div>
          </div>
        <% end %>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{system_object: system_object} = assigns, socket) do
    changeset = Space.change_system_object(system_object)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"system_object" => system_object_params}, socket) do
    system_object_params = convert_params(system_object_params)

    changeset =
      socket.assigns.system_object
      |> Space.change_system_object(system_object_params)
      |> Map.put(:action, :validate)

    notify_parent({:updated_changeset, changeset})

    {:noreply,
     socket
     |> assign_form(changeset)}
  end

  def handle_event("save", %{"system_object" => system_object_params}, socket) do
    system_object_params = convert_params(system_object_params)

    save_system_object(socket, socket.assigns.action, system_object_params)
  end

  defp save_system_object(socket, :edit, system_object_params) do
    case Space.update_system_object(socket.assigns.system_object, system_object_params) do
      {:ok, system_object} ->
        notify_parent({:saved, system_object})

        {:noreply,
         socket
         |> put_flash(:info, "SystemObject updated successfully")
         |> redirect(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_system_object(socket, :new, system_object_params) do
    case Space.create_system_object(system_object_params) do
      {:ok, system_object} ->
        notify_parent({:saved, system_object})

        {:noreply,
         socket
         |> put_flash(:info, "SystemObject created successfully")
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
