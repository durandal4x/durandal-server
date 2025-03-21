defmodule DurandalWeb.Game.UniverseFormComponent do
  @moduledoc false
  use DurandalWeb, :live_component

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
          <div class="col-md-12 col-lg-4">
            <h5>Scenario</h5>
            <.input
              label="Scenario:"
              field={@form[:scenario]}
              type="select"
              phx-debounce="100"
              options={[{"Basic", "basic"}, {"Empty", "empty"}]}
            />
            <br />

            <.input field={@form[:name]} type="text" phx-debounce="100" label="Name:" />
            <br />

            <.input field={@form[:active?]} type="checkbox" phx-debounce="100" label="Active?" />
            <br />
          </div>

          <div :if={@universe.id == nil} class="col-md-12 col-lg-4">
            <h5>Teams</h5>
            <div id="team-data">
              <div :for={team <- @scenario_team_data} class="mb-4">
                <.input
                  field={@form[:team_data]}
                  type="in_map"
                  key={[team["id"], "name"]}
                  actual_type="text"
                  label="Name: "
                />
              </div>
            </div>
            <br />

            <h5>Players</h5>
            <div id="user-data">
              <div :for={user <- @scenario_user_data} class="mb-4">
                <.input
                  field={@form[:user_data]}
                  type="in_map"
                  key={[user["id"], "id"]}
                  actual_type="hidden"
                />
                <.input
                  field={@form[:user_data]}
                  type="in_map"
                  key={[user["id"], "label"]}
                  actual_type="hidden"
                />

                <.input
                  field={@form[:user_data]}
                  type="in_map"
                  key={[user["id"], "name"]}
                  actual_type="text"
                  label={user["label"] <> " user"}
                />

                <.input
                  field={@form[:user_data]}
                  type="in_map"
                  key={[user["id"], "roles"]}
                  actual_type="text-array"
                  label={user["label"] <> " roles"}
                />
              </div>
            </div>
          </div>

          <div class="col-md-12 col-lg-4">
            <h5>Schedule</h5>
            <div :if={@show_schedule_warning} class="alert alert-warning">
              <Fontawesome.icon icon="triangle-exclamation" style="solid" class="text-warning" />
              Universe is active but has no tick schedule so will not run.
            </div>

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

    socket
    |> assign(:scenario_team_data, %{})
    |> assign(:scenario_user_data, %{})
    |> assign(:cached_scenario, nil)
    |> assign(assigns)
    |> assign_form(changeset)
    |> maybe_show_schedule_warning
    |> update_cached_scenario
    |> ok
  end

  @impl true
  def handle_event("validate", %{"universe" => universe_params}, socket) do
    universe_params = convert_unstructured_data(universe_params)

    changeset =
      socket.assigns.universe
      |> Game.change_universe(universe_params)
      |> Map.put(:action, :validate)

    notify_parent({:updated_changeset, changeset})

    socket
    |> assign_form(changeset)
    |> maybe_show_schedule_warning
    |> update_cached_scenario
    |> noreply
  end

  def handle_event("save", %{"universe" => universe_params}, socket) do
    save_universe(socket, socket.assigns.action, convert_unstructured_data(universe_params))
  end

  defp save_universe(socket, :edit, universe_params) do
    case Game.update_universe(socket.assigns.universe, universe_params) do
      {:ok, universe} ->
        notify_parent({:saved, universe})

        socket
        |> put_flash(:info, "Universe updated successfully")
        |> redirect(to: socket.assigns.patch)
        |> noreply

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_universe(socket, :new, universe_params) do
    {:ok, universe} =
      ScenarioLib.load_from_file(universe_params["scenario"],
        name: universe_params["name"],
        team_data: universe_params["team_data"],
        user_data: universe_params["user_data"]
      )

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

  defp convert_unstructured_data(params) do
    params
    # user_data = params["user_data"]
    #   |> Map.new(fn {k, v} -> {String.to_integer(k), v} end)

    # team_data = params["team_data"]
    #   |> Map.new(fn {k, v} -> {String.to_integer(k), v} end)

    # Map.merge(params, %{"user_data" => user_data, "team_data" => team_data})
  end

  defp update_cached_scenario(%{assigns: assigns} = socket) do
    selected_scenario = Ecto.Changeset.get_field(assigns.form.source, :scenario)

    if assigns.cached_scenario != selected_scenario do
      {scenario_team_data, scenario_user_data} =
        ScenarioLib.get_user_data_from_file(selected_scenario)

      team_data =
        scenario_team_data
        |> Map.new(fn data ->
          {data["id"],
           %{
             "id" => data["id"],
             "name" => Map.get(data, "name", "")
           }}
        end)

      user_data =
        scenario_user_data
        |> Map.new(fn data ->
          {data["id"],
           %{
             "id" => data["id"],
             "name" => Map.get(data, "default-name", ""),
             "roles" => Map.get(data, "roles", [])
           }}
        end)

      changeset =
        socket.assigns.form.source
        |> Ecto.Changeset.put_change(:team_data, team_data)
        |> Ecto.Changeset.put_change(:user_data, user_data)

      notify_parent({:updated_changeset, changeset})

      socket
      |> assign_form(changeset)
      |> assign(:cached_scenario, selected_scenario)
      |> assign(:scenario_team_data, scenario_team_data)
      |> assign(:scenario_user_data, scenario_user_data)
    else
      socket
    end
  end
end
