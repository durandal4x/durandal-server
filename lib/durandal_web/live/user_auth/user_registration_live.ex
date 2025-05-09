defmodule DurandalWeb.UserRegistrationLive do
  use DurandalWeb, :live_view

  alias Durandal.Account
  alias Durandal.Account.User

  def render(assigns) do
    ~H"""
    <div class="row" style="padding-top: 15vh;" id="registration-div">
      <div class="col-sm-12 col-md-10 offset-md-1 col-lg-8 offset-lg-2 col-xl-6 offset-xl-3 col-xxl-4 offset-xxl-4">
        <div class="card mb-3">
          <div class="card-body">
            <.header class="text-center">
              <img
                src={~p"/images/favicon.png"}
                height="42"
                style="margin-right: 5px;"
                class="d-inline align-top"
              /> {gettext("Register for an account")}
              <:subtitle>
                {gettext("Already registered?")}
                <.link navigate={~p"/login"} class="font-semibold text-brand hover:underline">
                  {gettext("Sign in")}
                </.link>
                {gettext("to your account now.")}
              </:subtitle>
            </.header>

            <.simple_form
              for={@form}
              id="registration_form"
              phx-submit="save"
              phx-change="validate"
              phx-trigger-action={@trigger_submit}
              action={~p"/login?_action=registered"}
              method="post"
            >
              <.error :if={@check_errors}>
                {gettext("Oops, something went wrong! Please check the errors below.")}
              </.error>

              <.input
                field={@form[:email]}
                type="email"
                label="Email"
                class="mt-2"
                required
                autofocus
              />
              <br />

              <.input field={@form[:name]} type="text" label="Display name" class="mt-2" required />
              <br />

              <.input field={@form[:password]} type="password" label="Password" class="mt-2" required />
              <br />

              <:actions>
                <.link class="btn btn-secondary float-start w-40" href="/">Cancel</.link>
              </:actions>

              <:actions>
                <.button phx-disable-with="Creating account..." class="btn-primary float-end w-40">
                  {gettext("Create an account")} <span aria-hidden="true">→</span>
                </.button>
              </:actions>
            </.simple_form>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Account.change_user(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil], layout: {DurandalWeb.Layouts, :blank}}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Account.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Account.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Account.change_user(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Account.change_user(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
