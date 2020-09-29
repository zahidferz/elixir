# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :chain_business_management,
  ecto_repos: [ChainBusinessManagement.Repo]

# Configures the endpoint
config :chain_business_management, ChainBusinessManagementWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "g8ZLNmG1wTTHYD9eIdL9aJmMmQm/Rw4oGk8Yzn6+VgQBVJKtwmIbh2NNcC+yjaed",
  render_errors: [
    view: ChainBusinessManagementWeb.ErrorView,
    accepts: ~w(html json),
    layout: false
  ],
  pubsub_server: ChainBusinessManagement.PubSub,
  live_view: [signing_salt: "XlBPhvmv"]

# Money configuration
config :money,
  default_currency: :MXN,
  symbol_on_right: false

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Timezone database
config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
