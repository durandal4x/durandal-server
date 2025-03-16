defmodule DurandalWeb.Space.StationFormComponent do
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
        id="station-form"
      >
        <div class="row mb-4">
          <%!-- Core properties --%>
          <div class="col-md-12 col-lg-6">
            <label for="station_name" class="control-label">Name:</label>
            <.input field={@form[:name]} type="text" autofocus="autofocus" phx-debounce="100" />
            <br />

            <label for="station_system_id" class="control-label">System:</label>
            <.input field={@form[:system_id]} type="select" options={@system_list} phx-debounce="100" />
            <br />

            <label for="station_team_id" class="control-label">Team:</label>
            <.input field={@form[:team_id]} type="select" options={@team_list} phx-debounce="100" />
            <br />
          </div>

          <div class="col-md-12 col-lg-6">
            <label for="station_position" class="control-label">Position:</label>
            <.input field={@form[:position]} type="3dvector" phx-debounce="100" />
            <br />

            <label for="station_velocity" class="control-label">Velocity:</label>
            <.input field={@form[:velocity]} type="3dvector" phx-debounce="100" />
            <br />
          </div>
        </div>

        <%= if @station.id do %>
          <div class="row">
            <div class="col">
              <a href={~p"/admin/stations/#{@station.id}"} class="btn btn-secondary btn-block">
                Cancel
              </a>
            </div>
            <div class="col">
              <button class="btn btn-primary btn-block" type="submit">Update station</button>
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
              <button class="btn btn-primary btn-block" type="submit">Create station</button>
            </div>
          </div>
        <% end %>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{station: station} = assigns, socket) do
    changeset = Space.change_station(station)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"station" => station_params}, socket) do
    station_params = convert_params(station_params)

    changeset =
      socket.assigns.station
      |> Space.change_station(station_params)
      |> Map.put(:action, :validate)

    notify_parent({:updated_changeset, changeset})

    {:noreply,
     socket
     |> assign_form(changeset)}
  end

  def handle_event("save", %{"station" => station_params}, socket) do
    station_params = convert_params(station_params)

    save_station(socket, socket.assigns.action, station_params)
  end

  defp save_station(socket, :edit, station_params) do
    case Space.update_station(socket.assigns.station, station_params) do
      {:ok, station} ->
        notify_parent({:saved, station})

        {:noreply,
         socket
         |> put_flash(:info, "Station updated successfully")
         |> redirect(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_station(socket, :new, station_params) do
    case Space.create_station(station_params) do
      {:ok, station} ->
        notify_parent({:saved, station})

        {:noreply,
         socket
         |> put_flash(:info, "Station created successfully")
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
