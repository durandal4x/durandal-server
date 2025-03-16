defmodule DurandalWeb.Space.SystemFormComponent do
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

      <.form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save" id="system-form">
        <div class="row mb-4">
          <%!-- Core properties --%>
          <div class="col-md-12 col-lg-6">
            <label for="system_name" class="control-label">Name:</label>
            <.input field={@form[:name]} type="text" autofocus="autofocus" phx-debounce="100" />

          </div>
        </div>

        <%= if @system.id do %>
          <div class="row">
            <div class="col">
              <a href={~p"/admin/systems/#{@system.id}"} class="btn btn-secondary btn-block">
                Cancel
              </a>
            </div>
            <div class="col">
              <button class="btn btn-primary btn-block" type="submit">Update system</button>
            </div>
          </div>
        <% else %>
          <div class="row">
            <div class="col">
              <a href={~p"/admin/systems/#{@universe_id}"} class="btn btn-secondary btn-block">
                Cancel
              </a>
            </div>
            <div class="col">
              <button class="btn btn-primary btn-block" type="submit">Create system</button>
            </div>
          </div>
        <% end %>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{system: system} = assigns, socket) do
    changeset = Space.change_system(system)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"system" => system_params}, socket) do
    system_params = convert_params(system_params)
      |> Map.put("universe_id", socket.assigns.universe_id)

    changeset =
      socket.assigns.system
      |> Space.change_system(system_params)
      |> Map.put(:action, :validate)

    notify_parent({:updated_changeset, changeset})

    {:noreply,
     socket
     |> assign_form(changeset)}
  end

  def handle_event("save", %{"system" => system_params}, socket) do
    system_params = convert_params(system_params)
      |> Map.put("universe_id", socket.assigns.universe_id)

    save_system(socket, socket.assigns.action, system_params)
  end

  defp save_system(socket, :edit, system_params) do
    case Space.update_system(socket.assigns.system, system_params) do
      {:ok, system} ->
        notify_parent({:saved, system})

        {:noreply,
         socket
         |> put_flash(:info, "User updated successfully")
         |> redirect(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_system(socket, :new, system_params) do
    case Space.create_system(system_params) do
      {:ok, system} ->
        notify_parent({:saved, system})

        {:noreply,
         socket
         |> put_flash(:info, "User created successfully")
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
