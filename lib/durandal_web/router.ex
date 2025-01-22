defmodule DurandalWeb.Router do
  use DurandalWeb, :router

  import DurandalWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {DurandalWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :maybe_auth do
    plug DurandalWeb.AuthPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DurandalWeb.General do
    pipe_through [:browser]

    live_session :general_index,
      on_mount: [
        {DurandalWeb.UserAuth, :mount_current_user}
      ] do
      live "/", HomeLive.Index, :index
      live "/guest", HomeLive.Guest, :index
    end
  end

  scope "/", DurandalWeb do
    pipe_through [:browser, :maybe_auth]

    get "/readme", PageController, :readme
  end

  scope "/admin", DurandalWeb.Admin do
    pipe_through [:browser]

    live_session :admin_index,
      on_mount: [
        {DurandalWeb.UserAuth, :ensure_authenticated},
        {DurandalWeb.UserAuth, {:authorise, "admin"}}
      ] do
      live "/", HomeLive, :index
    end
  end

  scope "/admin/accounts", DurandalWeb.Admin.Account do
    pipe_through [:browser]

    live_session :admin_accounts,
      on_mount: [
        {DurandalWeb.UserAuth, :ensure_authenticated},
        {DurandalWeb.UserAuth, {:authorise, ~w(admin)}}
      ] do
      live "/", IndexLive
      live "/user/new", NewLive
      live "/user/edit/:user_id", ShowLive, :edit
      live "/user/:user_id", ShowLive
    end
  end

  scope "/admin/games", DurandalWeb.Admin.Game do
    pipe_through [:browser]

    live_session :admin_game_index,
      on_mount: [
        {DurandalWeb.UserAuth, :ensure_authenticated},
        {DurandalWeb.UserAuth, {:authorise, "admin"}}
      ] do
      live "/", HomeLive, :index
    end
  end

  scope "/admin/games/universes", DurandalWeb.Admin.Game.Universe do
    pipe_through [:browser]

    live_session :admin_universes,
      on_mount: [
        {DurandalWeb.UserAuth, :ensure_authenticated},
        {DurandalWeb.UserAuth, {:authorise, ~w(admin)}}
      ] do
      live "/", IndexLive
      live "/new", NewLive
      live "/edit/:universe_id", ShowLive, :edit
      live "/delete/:universe_id", ShowLive, :delete
      live "/:universe_id", ShowLive
    end
  end

  # scope "/play", DurandalWeb.Play do
  #   pipe_through [:browser]

  #   live_session :play_index,
  #     on_mount: [
  #       {DurandalWeb.UserAuth, :ensure_authenticated}
  #     ] do
  #     live "/new", NewLive.Index, :index
  #     live "/find", FindLive.Index, :index
  #     live "/find/:game_id", FindLive.Index, :game
  #   end

  #   live_session :play_in_game,
  #     on_mount: [
  #       {DurandalWeb.UserAuth, :ensure_authenticated}
  #     ] do
  #     live "/ward/:game_id", WardLive.Index, :index
  #     live "/patients/:game_id", PatientsLive.Index, :index
  #     live "/desk/:game_id", DeskLive.Index, :index
  #     live "/job/:game_id/:job_id", JobLive.Index, :index
  #   end
  # end

  scope "/", DurandalWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{DurandalWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/login", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    get "/login/:code", UserSessionController, :login_from_code
    post "/login", UserSessionController, :create
  end

  scope "/", DurandalWeb do
    pipe_through [:browser]

    delete "/logout", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{DurandalWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  scope "/admin", DurandalWeb.Admin do
    pipe_through [:browser]
    import Phoenix.LiveDashboard.Router

    live_dashboard("/live_dashboard",
      metrics: Durandal.TelemetrySupervisor,
      ecto_repos: [Durandal.Repo],
      on_mount: [
        {DurandalWeb.UserAuth, :ensure_authenticated},
        {DurandalWeb.UserAuth, {:authorise, "admin"}}
      ],
      additional_pages: [
        # live_dashboard_additional_pages
      ]
    )
  end
end
