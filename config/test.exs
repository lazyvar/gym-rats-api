use Mix.Config

# Configure your database
config :gym_rats, GymRats.Repo,
  username: "postgres",
  password: "postgres",
  database: "gym_rats_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :gym_rats, GymRatsWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :joken, default_signer: "secrets secrets are fun"
