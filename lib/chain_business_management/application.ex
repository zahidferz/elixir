defmodule ChainBusinessManagement.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ChainBusinessManagement.Repo,
      # Start the Income sales repo
      ChainBusinessManagement.IncomeSalesRepo,
      # Start the Users repo
      ChainBusinessManagement.UsersRepo,
      # Start the Telemetry supervisor
      ChainBusinessManagementWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ChainBusinessManagement.PubSub},
      # Start the Endpoint (http/https)
      ChainBusinessManagementWeb.Endpoint,
      # Start the accounts  task scheduler
      ChainBusinessManagement.TaskScheduler.Accounts
      # Start a worker by calling: ChainBusinessManagement.Worker.start_link(arg)
      # {ChainBusinessManagement.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ChainBusinessManagement.Supervisor]
    sup_result = Supervisor.start_link(children, opts)
    ChainBusinessManagement.TaskScheduler.Accounts.setup_jobs()

    sup_result
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ChainBusinessManagementWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
