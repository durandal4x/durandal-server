defmodule DurandalWeb.UserLoginLive do
  use DurandalWeb, :live_view

  # use Phoenix.LiveView, layout: {DurandalWeb.Layouts, :blank}

  def render(assigns) do
    ~H"""
    <div class="row" style="padding-top: 15vh;" id="login-div">
      <div class="col-sm-12 col-md-10 offset-md-1 col-lg-8 offset-lg-2 col-xl-6 offset-xl-3 col-xxl-4 offset-xxl-4">
        <div class="card mb-3">
          <div class="card-body">
            <h3>
              <img
                src={~p"/images/favicon.png"}
                height="42"
                style="margin-right: 5px;"
                class="d-inline align-top"
              /> {gettext("Sign In")}
            </h3>

            <.simple_form for={@form} id="login_form" action={~p"/login"} phx-update="ignore">
              <.input
                field={@form[:email]}
                type="email"
                label="Email"
                autofocus="autofocus"
                tabindex="1"
                required
              />
              <br />

              <.link href={~p"/users/reset_password"} class="float-end" tabindex="-1">
                {gettext("Forgot your password?")}
              </.link>
              <.input field={@form[:password]} type="password" label="Password" tabindex="2" required />
              <br />

              <:actions>
                <div class="float-start">
                  <.input
                    field={@form[:remember_me]}
                    type="checkbox"
                    tabindex="3"
                    label="Keep me logged in"
                  />
                </div>
              </:actions>
              <:actions>
                <.button
                  phx-disable-with="Signing in..."
                  class="btn btn-primary float-end w-40"
                  tabindex="40"
                >
                  {gettext("Login")} <span aria-hidden="true">→</span>
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
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")

    {:ok, assign(socket, form: form),
     temporary_assigns: [form: form], layout: {DurandalWeb.Layouts, :blank}}
  end
end
