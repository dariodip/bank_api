# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :bank_api,
  namespace: BankAPI,
  ecto_repos: [BankAPI.Repo]

# Configures the endpoint
config :bank_api, BankAPIWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "vXtdmGYUmqCZ8z+KdPe0UXBgb0LUguUw3ibNRdVLBU7Ofrm7jzc9R82Ekq2jwX97",
  render_errors: [view: BankAPIWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: BankAPI.PubSub,
  live_view: [signing_salt: "VPxYvr5c"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :bank_api, event_stores: [BankAPI.EventStore]

config :bank_api, BankAPI.Commanded,
  event_store: [
    adapter: Commanded.EventStore.Adapters.EventStore,
    event_store: BankAPI.EventStore
  ],
  registry: :local,
  pubsub: :local

config :bank_api, BankAPI.EventStore,
  column_data_type: "jsonb",
  serializer: EventStore.JsonbSerializer,
  types: EventStore.PostgresTypes

config :bank_api,
  projectors_supervisor_children: [
    BankAPI.Accounts.Projectors.AccountOpened,
    BankAPI.Accounts.Projectors.AccountClosed,
    BankAPI.Accounts.Projectors.DepositsAndWithdrawals,
    BankAPI.Accounts.ProcessManagers.TransferMoney
  ]

config :commanded_ecto_projections, repo: BankAPI.Repo

config :bank_api, :process_manager_idle_timeout, :timer.minutes(10)

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
