defmodule DurandalWeb.Types.ShipTypeFormComponent do
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
        id="ship_type-form"
      >
        <div class="row mb-4">
          <%!-- Core properties --%>
          <div class="col-md-12 col-lg-6">
            <label for="ship_type_name" class="control-label">Name:</label>
            <.input field={@form[:name]} type="text" autofocus="autofocus" phx-debounce="100" />
            <br />

            <label for="ship_type_build_time" class="control-label">Build time:</label>
            <.input field={@form[:build_time]} type="text" phx-debounce="100" />
            <br />

            <label for="ship_type_max_health" class="control-label">Max health:</label>
            <.input field={@form[:max_health]} type="text" phx-debounce="100" />
            <br />
          </div>

          <div :if={Ecto.assoc_loaded?(@ship_type.universe)} class="col-md-12 col-lg-6">
            <label for="ship_type_name" class="control-label">Universe:</label>
            <.input
              value={@ship_type.universe.name}
              name="ship_type_universe"
              type="text"
              disabled="disabled"
            />
            <br />

            <label for="ship_type_acceleration" class="control-label">Acceleration:</label>
            <.input field={@form[:acceleration]} type="text" phx-debounce="100" />
            <br />

            <label for="ship_type_damage" class="control-label">Damage:</label>
            <.input field={@form[:damage]} type="text" phx-debounce="100" />
            <br />
          </div>
        </div>

        <%= if @ship_type.id do %>
          <div class="row">
            <div class="col">
              <a href={~p"/admin/ship_types/#{@ship_type.id}"} class="btn btn-secondary btn-block">
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
  def update(%{ship_type: ship_type} = assigns, socket) do
    changeset = Types.change_ship_type(ship_type)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"ship_type" => ship_type_params}, socket) do
    ship_type_params = convert_params(ship_type_params)

    changeset =
      socket.assigns.ship_type
      |> Types.change_ship_type(ship_type_params)
      |> Map.put(:action, :validate)

    notify_parent({:updated_changeset, changeset})

    {:noreply,
     socket
     |> assign_form(changeset)}
  end

  def handle_event("save", %{"ship_type" => ship_type_params}, socket) do
    ship_type_params = convert_params(ship_type_params)

    save_ship_type(socket, socket.assigns.action, ship_type_params)
  end

  defp save_ship_type(socket, :edit, ship_type_params) do
    case Types.update_ship_type(socket.assigns.ship_type, ship_type_params) do
      {:ok, ship_type} ->
        notify_parent({:saved, ship_type})

        {:noreply,
         socket
         |> put_flash(:info, "Team updated successfully")
         |> redirect(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_ship_type(socket, :new, ship_type_params) do
    case Types.create_ship_type(ship_type_params) do
      {:ok, ship_type} ->
        notify_parent({:saved, ship_type})

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
