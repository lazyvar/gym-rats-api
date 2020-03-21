use Mix.Config

# Configure your database
config :gym_rats, GymRats.Repo,
  username: "postgres",
  password: "postgres",
  database: "gym_rats_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :gym_rats, GymRatsWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false

config :gym_rats, GymRats.Mailer, adapter: Bamboo.LocalAdapter

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime

config :joken, default_signer: "opensesamebagel"
