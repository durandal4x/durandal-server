defmodule DurandalWeb.Player.TeamFormComponent do
  @moduledoc false
  use DurandalWeb, :live_component
  # import Durandal.Helper.ColourHelper, only: [rgba_css: 2]

  alias Durandal.Player

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h3>
        {@title}
      </h3>

      <.form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save" id="team-form">
        <div class="row mb-4">
          <%!-- Core properties --%>
          <div class="col-md-12 col-lg-6">
            <label for="team_name" class="control-label">Name:</label>
            <.input field={@form[:name]} type="text" autofocus="autofocus" phx-debounce="100" />
            <br />
          </div>

          <div :if={Ecto.assoc_loaded?(@team.universe)} class="col-md-12 col-lg-6">
            <label for="team_name" class="control-label">Universe:</label>
            <.input value={@team.universe.name} name="team_universe" type="text" disabled="disabled" />
            <br />
          </div>
        </div>

        <%= if @team.id do %>
          <div class="row">
            <div class="col">
              <a href={~p"/admin/teams/#{@team.id}"} class="btn btn-secondary btn-block">
                Cancel
              </a>
            </div>
            <div class="col">
              <button class="btn btn-primary btn-block" type="submit">Update team</button>
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
              <button class="btn btn-primary btn-block" type="submit">Create team</button>
            </div>
          </div>
        <% end %>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{team: team} = assigns, socket) do
    changeset = Player.change_team(team)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"team" => team_params}, socket) do
    team_params = convert_params(team_params)

    changeset =
      socket.assigns.team
      |> Player.change_team(team_params)
      |> Map.put(:action, :validate)

    notify_parent({:updated_changeset, changeset})

    {:noreply,
     socket
     |> assign_form(changeset)}
  end

  def handle_event("save", %{"team" => team_params}, socket) do
    team_params = convert_params(team_params)

    save_team(socket, socket.assigns.action, team_params)
  end

  defp save_team(socket, :edit, team_params) do
    case Player.update_team(socket.assigns.team, team_params) do
      {:ok, team} ->
        notify_parent({:saved, team})

        {:noreply,
         socket
         |> put_flash(:info, "Team updated successfully")
         |> redirect(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_team(socket, :new, team_params) do
    case Player.create_team(team_params) do
      {:ok, team} ->
        notify_parent({:saved, team})

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
