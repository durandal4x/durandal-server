defmodule DurandalWeb.Space.StationModuleFormComponent do
  @moduledoc false
  use DurandalWeb, :live_component
  # import Durandal.Helper.ColourHelper, only: [rgba_css: 2]

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
        id="station_module-form"
      >
        <div class="row mb-4">
          <%!-- Core properties --%>
          <div class="col-md-12 col-lg-6">
            <label for="station_module_type_id" class="control-label">Type:</label>
            <.input field={@form[:type_id]} type="select" options={@type_list} phx-debounce="100" />
            <br />

            <label for="station_module_station_id" class="control-label">Station:</label>
            <.input
              field={@form[:station_id]}
              type="select"
              options={@station_list}
              phx-debounce="100"
            />
            <br />
          </div>

          <div class="col-md-12 col-lg-6">
            <label for="station_module_build_progress" class="control-label">Build progress:</label>
            <.input
              field={@form[:build_progress]}
              type="text"
              autofocus="autofocus"
              phx-debounce="100"
            />
            <br />

            <label for="station_module_health" class="control-label">Health:</label>
            <.input field={@form[:health]} type="text" phx-debounce="100" />
            <br />
          </div>
        </div>

        <%= if @station_module.id do %>
          <div class="row">
            <div class="col">
              <a
                href={~p"/admin/station_modules/#{@station_module.id}"}
                class="btn btn-secondary btn-block"
              >
                Cancel
              </a>
            </div>
            <div class="col">
              <button class="btn btn-primary btn-block" type="submit">Update station_module</button>
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
              <button class="btn btn-primary btn-block" type="submit">Create station_module</button>
            </div>
          </div>
        <% end %>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{station_module: station_module} = assigns, socket) do
    changeset = Space.change_station_module(station_module)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"station_module" => station_module_params}, socket) do
    station_module_params = convert_params(station_module_params)

    changeset =
      socket.assigns.station_module
      |> Space.change_station_module(station_module_params)
      |> Map.put(:action, :validate)

    notify_parent({:updated_changeset, changeset})

    {:noreply,
     socket
     |> assign_form(changeset)}
  end

  def handle_event("save", %{"station_module" => station_module_params}, socket) do
    station_module_params = convert_params(station_module_params)

    save_station_module(socket, socket.assigns.action, station_module_params)
  end

  defp save_station_module(socket, :edit, station_module_params) do
    case Space.update_station_module(socket.assigns.station_module, station_module_params) do
      {:ok, station_module} ->
        notify_parent({:saved, station_module})

        {:noreply,
         socket
         |> put_flash(:info, "StationModule updated successfully")
         |> redirect(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_station_module(socket, :new, station_module_params) do
    case Space.create_station_module(station_module_params) do
      {:ok, station_module} ->
        notify_parent({:saved, station_module})

        {:noreply,
         socket
         |> put_flash(:info, "StationModule created successfully")
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
