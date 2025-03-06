defmodule DurandalWeb.Player.TeamMemberFormComponent do
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

      <.form
        for={@form}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        id="team_member-form"
      >
        <div class="row mb-4">
          <%!-- Core properties --%>
          <div class="col-md-12 col-lg-6">
            <.input field={@form[:enabled?]} type="checkbox" autofocus="autofocus" phx-debounce="100" label="Enabled?" />
            <br />

          </div>
        </div>

        <%= if @team_member.user_id do %>
          <div class="row">
            <div class="col">
              <a
                href={~p"/admin/team_members/#{@team_member.team_id}/#{@team_member.user_id}"}
                class="btn btn-secondary btn-block"
              >
                Cancel
              </a>
            </div>
            <div class="col">
              <button class="btn btn-primary btn-block" type="submit">Update team_member</button>
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
              <button class="btn btn-primary btn-block" type="submit">Create team_member</button>
            </div>
          </div>
        <% end %>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{team_member: team_member} = assigns, socket) do
    changeset = Player.change_team_member(team_member)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"team_member" => team_member_params}, socket) do
    team_member_params = convert_params(team_member_params)

    changeset =
      socket.assigns.team_member
      |> Player.change_team_member(team_member_params)
      |> Map.put(:action, :validate)

    notify_parent({:updated_changeset, changeset})

    {:noreply,
     socket
     |> assign_form(changeset)}
  end

  def handle_event("save", %{"team_member" => team_member_params}, socket) do
    team_member_params = convert_params(team_member_params)

    save_team_member(socket, socket.assigns.action, team_member_params)
  end

  defp save_team_member(socket, :edit, team_member_params) do
    case Player.update_team_member(socket.assigns.team_member, team_member_params) do
      {:ok, team_member} ->
        notify_parent({:saved, team_member})

        {:noreply,
         socket
         |> put_flash(:info, "TeamMember updated successfully")
         |> redirect(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_team_member(socket, :new, team_member_params) do
    case Player.create_team_member(team_member_params) do
      {:ok, team_member} ->
        notify_parent({:saved, team_member})

        {:noreply,
         socket
         |> put_flash(:info, "TeamMember created successfully")
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
