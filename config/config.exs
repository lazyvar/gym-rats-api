# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :gym_rats,
  ecto_repos: [GymRats.Repo]

# Configures the endpoint
config :gym_rats, GymRatsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "YsZeGi6q/Mlj0Onlr2I5gsmzhqsmDPMEpAvpN9zffocH7wth9mRX4OxLL+ZWm0Wa",
  render_errors: [view: GymRatsWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: GymRats.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# user guardian for JWT auth stuff
config :gym_rats, GymRats.Guardian,
       issuer: "gym_rats",
       secret_key: System.get_env("gymrats_jwt_secret")

config :joken, default_signer: System.get_env("gymrats_jwt_secret")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
