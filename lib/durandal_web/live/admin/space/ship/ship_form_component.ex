defmodule DurandalWeb.Space.ShipFormComponent do
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

      <.form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save" id="ship-form">
        <div class="row mb-4">
          <%!-- Core properties --%>
          <div class="col-md-12 col-lg-6">
            <label for="ship_name" class="control-label">Name:</label>
            <.input field={@form[:name]} type="text" autofocus="autofocus" phx-debounce="100" />
            <br />

            <label for="ship_type_id" class="control-label">Type:</label>
            <.input field={@form[:type_id]} type="select" options={@type_list} phx-debounce="100" />
            <br />

            <label for="ship_team_id" class="control-label">Team:</label>
            <.input field={@form[:team_id]} type="select" options={@team_list} phx-debounce="100" />
            <br />

            <label for="ship_system_id" class="control-label">System:</label>
            <.input field={@form[:system_id]} type="select" options={@system_list} phx-debounce="100" />
            <br />
          </div>

          <div class="col-md-12 col-lg-6">
            <label for="ship_position" class="control-label">Position:</label>
            <.input field={@form[:position]} type="3dvector" phx-debounce="100" />
            <br />

            <label for="ship_velocity" class="control-label">Velocity:</label>
            <.input field={@form[:velocity]} type="3dvector" phx-debounce="100" />
            <br />
          </div>
        </div>

        <%= if @ship.id do %>
          <div class="row">
            <div class="col">
              <a href={~p"/admin/ships/#{@ship.id}"} class="btn btn-secondary btn-block">
                Cancel
              </a>
            </div>
            <div class="col">
              <button class="btn btn-primary btn-block" type="submit">Update ship</button>
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
              <button class="btn btn-primary btn-block" type="submit">Create ship</button>
            </div>
          </div>
        <% end %>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{ship: ship} = assigns, socket) do
    changeset = Space.change_ship(ship)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"ship" => ship_params}, socket) do
    ship_params = convert_params(ship_params)

    changeset =
      socket.assigns.ship
      |> Space.change_ship(ship_params)
      |> Map.put(:action, :validate)

    notify_parent({:updated_changeset, changeset})

    {:noreply,
     socket
     |> assign_form(changeset)}
  end

  def handle_event("save", %{"ship" => ship_params}, socket) do
    ship_params = convert_params(ship_params)

    save_ship(socket, socket.assigns.action, ship_params)
  end

  defp save_ship(socket, :edit, ship_params) do
    case Space.update_ship(socket.assigns.ship, ship_params) do
      {:ok, ship} ->
        notify_parent({:saved, ship})

        {:noreply,
         socket
         |> put_flash(:info, "Ship updated successfully")
         |> redirect(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_ship(socket, :new, ship_params) do
    case Space.create_ship(ship_params) do
      {:ok, ship} ->
        notify_parent({:saved, ship})

        {:noreply,
         socket
         |> put_flash(:info, "Ship created successfully")
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
