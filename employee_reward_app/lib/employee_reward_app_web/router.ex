defmodule EmployeeRewardAppWeb.Router do
  use EmployeeRewardAppWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {EmployeeRewardAppWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :session_line do
    plug(EmployeeRewardApp.AuthAccessPipeline)
    plug(EmployeeRewardAppWeb.CurrentUser)
  end

  pipeline :login_pipeline do
    plug(EmployeeRewardApp.LoginPipeline)
    plug(EmployeeRewardAppWeb.CurrentUser)
  end

  #pipeline :admin_pipeline do
  #  plug(EmployeeRewardApp.LoginPipeline)
  #  plug(EmployeeRewardAppWeb.CurrentUser)
  #end

  scope "/", EmployeeRewardAppWeb do
    pipe_through([:browser, :session_line])

    get("/", PageController, :index)

    resources("/sessions", SessionController, only: [:delete])
    resources("/addpoints", PointsController, only: [:new, :create])
  end

  scope "/user", EmployeeRewardAppWeb do
    pipe_through([:browser, :login_pipeline])
    get("/new", UserController, :new)
    get("/show/:id", UserController, :show)
    get("/rewards/:id", UserController, :rewards)
    get("/settings/:id", UserController, :settings)
    post("/create", UserController, :create)
    post("/settings/change_password", UserController, :change_password)
  end

 # scope "/admin", EmployeeRewardAppWeb do
 #   pipe_through([:browser, :admin_pipeline])
 #   get("/new", AdminController, :new)
 #   get("/show/:id", AdminController, :show)
 #   post("/create", AdminController, :create)
 # end

  scope "/sessions", EmployeeRewardAppWeb do
    pipe_through([:browser, :login_pipeline])

    get("/new", SessionController, :new)
    post("/create", SessionController, :create)
  end

  # Other scopes may use custom stacks.
  # scope "/api", EmployeeRewardAppWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: EmployeeRewardAppWeb.Telemetry)
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through(:browser)

      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
