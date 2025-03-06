defmodule DurandalWeb.Game.UniverseFormComponent do
  @moduledoc false
  use DurandalWeb, :live_component
  # import Durandal.Helper.ColourHelper, only: [rgba_css: 2]

  alias Durandal.Game
  alias Durandal.Game.{ScenarioLib}

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
        id="universe-form"
      >
        <div class="row mb-4">
          <%!-- Core properties --%>
          <div class="col-md-12 col-lg-6">
            <.input
              field={@form[:name]}
              type="text"
              autofocus="autofocus"
              phx-debounce="100"
              label="Name:"
            />
            <br />

            <.input field={@form[:active?]} type="checkbox" phx-debounce="100" label="Active?" />
            <br />

            <.input
              label="Scenario:"
              field={@form[:scenario]}
              type="select"
              phx-debounce="100"
              options={[{"Basic", "basic"}, {"Empty", "empty"}]}
            />
            <br />
          </div>

          <div class="col-md-12 col-lg-6">
            <.input
              field={@form[:tick_schedule]}
              type="text"
              phx-debounce="100"
              label="Schedule:"
              placeholder="5 minutes"
            />
            <br />

            <.input
              field={@form[:tick_seconds]}
              type="text"
              label="Tick duration in seconds:"
              disabled="disabled"
            />
            <br />

            <.input
              field={@form[:last_tick]}
              type="datetime-local"
              label="Last tick:"
              disabled="disabled"
            />
            <br />

            <.input
              field={@form[:next_tick]}
              type="datetime-local"
              label="Next tick:"
              disabled="disabled"
            />
          </div>
        </div>

        <div :if={@show_schedule_warning} class="row">
          <div class="col">
            <div class="alert alert-warning">
              <Fontawesome.icon icon="triangle-exclamation" style="solid" class="text-warning" />
              Universe is active but has no tick schedule so will not run.
            </div>
          </div>
        </div>

        <%= if @universe.id do %>
          <div class="row">
            <div class="col">
              <a href={~p"/admin/universes/#{@universe.id}"} class="btn btn-secondary btn-block">
                Cancel
              </a>
            </div>
            <div class="col">
              <button class="btn btn-primary btn-block" type="submit">Update universe</button>
            </div>
          </div>
        <% else %>
          <div class="row">
            <div class="col">
              <a href={~p"/admin/universes"} class="btn btn-secondary btn-block">
                Cancel
              </a>
            </div>
            <div class="col">
              <button class="btn btn-primary btn-block" type="submit">Create universe</button>
            </div>
          </div>
        <% end %>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{universe: universe} = assigns, socket) do
    changeset = Game.change_universe(universe)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)
     |> maybe_show_schedule_warning}
  end

  @impl true
  def handle_event("validate", %{"universe" => universe_params}, socket) do
    universe_params = convert_params(universe_params)

    changeset =
      socket.assigns.universe
      |> Game.change_universe(universe_params)
      |> Map.put(:action, :validate)

    notify_parent({:updated_changeset, changeset})

    {:noreply,
     socket
     |> assign_form(changeset)
     |> maybe_show_schedule_warning}
  end

  def handle_event("save", %{"universe" => universe_params}, socket) do
    universe_params = convert_params(universe_params)

    save_universe(socket, socket.assigns.action, universe_params)
  end

  defp save_universe(socket, :edit, universe_params) do
    case Game.update_universe(socket.assigns.universe, universe_params) do
      {:ok, universe} ->
        notify_parent({:saved, universe})

        {:noreply,
         socket
         |> put_flash(:info, "Universe updated successfully")
         |> redirect(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_universe(socket, :new, universe_params) do
    {:ok, universe} =
      ScenarioLib.load_from_file(universe_params["scenario"], name: universe_params["name"])

    case Game.update_universe(universe, universe_params) do
      {:ok, universe} ->
        notify_parent({:saved, universe})

        {:noreply,
         socket
         |> put_flash(:info, "Universe created successfully")
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

  defp maybe_show_schedule_warning(%{assigns: %{form: form}} = socket) do
    active? = Ecto.Changeset.get_field(form.source, :active?)
    tick_seconds = Ecto.Changeset.get_field(form.source, :tick_seconds)
    show_schedule_warning = active? && (tick_seconds == nil || tick_seconds < 1)

    socket
    |> assign(:show_schedule_warning, show_schedule_warning)
  end

  defp maybe_show_schedule_warning(socket) do
    socket
    |> assign(:show_schedule_warning, false)
  end
end
