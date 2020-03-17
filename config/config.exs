use Mix.Config

config :gym_rats,
  ecto_repos: [GymRats.Repo]

config :gym_rats, GymRatsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "YsZeGi6q/Mlj0Onlr2I5gsmzhqsmDPMEpAvpN9zffocH7wth9mRX4OxLL+ZWm0Wa",
  render_errors: [view: GymRatsWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: GymRats.PubSub, adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :ex_twilio,
  account_sid: {:system, "TWILIO_ACCOUNT_SID"},
  auth_token: {:system, "TWILIO_AUTH_TOKEN"}

config :pigeon, :apns,
  apns_default: %{
    cert: "cert.pem",
    key: "key.pem",
    mode: Mix.env()
  }

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
