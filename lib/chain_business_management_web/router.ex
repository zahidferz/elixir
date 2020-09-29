defmodule ChainBusinessManagementWeb.Router do
  use ChainBusinessManagementWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ChainBusinessManagementWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", ChainBusinessManagementWeb.Api do
    pipe_through :api

    scope "/v1", V1 do
      resources "/accounts", AccountController, only: [:create, :update]

      get "/monthly_sales", SalesSummaryController, :monthly_sales
      get "/year_sales", SalesSummaryController, :year_sales

      resources "/operations", OperationController, only: [:create]
      resources "/operations/sales", SalesOperationController, only: [:delete]

      resources "/operations/sales/company", SalesCompanyOperationController,
        only: [:show],
        param: "company_number"

      get "/companies/:company_number/receivables", ReceivablesController, :index
    end
  end

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
      pipe_through :browser
      live_dashboard "/dashboard", metrics: ChainBusinessManagementWeb.Telemetry
    end
  end
end
