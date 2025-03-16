defmodule DurandalWeb.Account.UserPasswordFormComponent do
  @moduledoc false
  use DurandalWeb, :live_component

  alias Durandal.Account

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
        phx-submit="save_password"
        id="user-pw-form"
      >
        <div class="row mb-4">
          <%!-- Core properties --%>
          <div class="col-md-12 my-2">
            <label for="user_existing" class="control-label">Current password:</label>
            <.input field={@form[:existing]} type="password" phx-debounce="1000" autocomplete="off" />
          </div>

          <div class="col-md-12 my-2">
            <label for="user_new_password" class="control-label">New password:</label>
            <.input
              field={@form[:new_password]}
              type="password"
              phx-debounce="100"
              autocomplete="off"
            />
          </div>

          <div class="col-md-12 my-2">
            <label for="user_new_password_confirm" class="control-label">Confirm new password:</label>
            <.input
              field={@form[:new_password_confirm]}
              type="password"
              phx-debounce="100"
              autocomplete="off"
            />
          </div>
        </div>

        <div class="row">
          <div class="col">
            <a href={~p"/admin/accounts/user/#{@user.id}"} class="btn btn-secondary btn-block">
              Cancel
            </a>
          </div>
          <div class="col">
            <button class="btn btn-primary2 btn-block" type="submit">Update password</button>
          </div>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{user: user} = assigns, socket) do
    # This prevents us from having the user password in the HTML
    changeset =
      user
      |> struct(%{password: ""})
      |> Account.change_user()

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> Account.User.changeset(user_params, :change_password)
      |> Map.put(:action, :validate)

    notify_parent({:updated_changeset, changeset})

    {:noreply,
     socket
     |> assign_form(changeset)}
  end

  def handle_event("save_password", %{"user" => user_params}, socket) do
    save_user(socket, socket.assigns.action, user_params)
  end

  defp save_user(socket, :edit_password, user_params) do
    user_params =
      Map.merge(user_params, %{
        "password" => user_params["new_password"],
        "password_confirm" => user_params["new_password"]
      })

    case Account.UserLib.update_password(socket.assigns.user, user_params) do
      {:ok, user} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, "User password updated successfully")
         |> redirect(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
