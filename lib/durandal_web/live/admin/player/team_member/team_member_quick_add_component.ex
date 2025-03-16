defmodule DurandalWeb.Player.TeamMemberQuickAddComponent do
  @moduledoc false
  use DurandalWeb, :live_component

  alias Durandal.{Account, Player}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        id="quick_add_team_member-form"
      >
        <div class="row mb-4">
          <.input field={@form[:universe_id]} type="hidden" />
          <.input field={@form[:team_id]} type="hidden" />

          <div class="col-md-10">
            <.input field={@form[:user_id]} type="hidden" />
            <.input
              field={@form[:name]}
              type="text"
              phx-debounce="200"
              placeholder="User name"
              show_valid={true}
              valid_inset={true}
            />
          </div>
          <div class="col-md-2">
            <button class="btn btn-primary btn-block" type="submit">
              <Fontawesome.icon icon="plus" style="regular" />
            </button>
          </div>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{team_member: team_member} = assigns, socket) do
    changeset = Player.change_team_member(team_member)

    existing_members =
      Player.list_team_members(where: [team_id: team_member.team_id], select: [:user_id])
      |> Enum.map(& &1.user_id)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:existing_members, existing_members)
     |> assign_form(changeset)
     |> assign(:last_name_lookup, nil)}
  end

  @impl true
  def handle_event("validate", %{"team_member" => team_member_params}, socket) do
    team_member_params =
      convert_params(team_member_params)
      |> maybe_lookup_user_name(socket.assigns.last_name_lookup)

    changeset =
      socket.assigns.team_member
      |> Player.change_team_member(team_member_params)
      |> Map.put(:action, :validate)
      |> maybe_error_name(socket.assigns.existing_members)

    notify_parent({:updated_changeset, changeset})

    {:noreply,
     socket
     |> assign_form(changeset)}
  end

  def handle_event("save", %{"team_member" => team_member_params}, socket) do
    team_member_params = convert_params(team_member_params)

    if socket.assigns.form.source.valid? do
      case Player.create_team_member(team_member_params) do
        {:ok, team_member} ->
          notify_parent({:saved, team_member})

          socket
          |> put_flash(:info, "TeamMember created successfully")
          |> redirect(to: socket.assigns.patch)
          |> noreply

        {:error, %Ecto.Changeset{} = changeset} ->
          changeset = changeset
          |> maybe_error_name(socket.assigns.existing_members)

          {:noreply, assign_form(socket, changeset)}
      end
    else
      socket
      |> noreply
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp convert_params(params) do
    params
    |> Map.put("roles", [])
  end

  defp maybe_lookup_user_name(params, last_lookup_name) do
    cond do
      last_lookup_name == params["name"] ->
        params

      params["name"] == "" ->
        Map.put(params, "user_id", nil)

      true ->
        user = Account.get_user_by_name(params["name"])
        Map.put(params, "user_id", user && user.id)
    end
  end

  defp maybe_error_name(changeset, existing_members) do
    cond do
      changeset.changes[:user_id] in existing_members ->
        changeset
        |> Ecto.Changeset.add_error(:name, "That user is already a team member")

      changeset.errors[:user_id] == nil ->
        changeset

      true ->
        changeset
        |> Ecto.Changeset.add_error(:name, "No user of that name found")
    end
  end
end
