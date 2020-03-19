use Mix.Config

# Configure your database
config :gym_rats, GymRats.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("POSTGRES_USER") || "postgres",
  password: System.get_env("POSTGRES_PASSWORD") || "postgres",
  database: System.get_env("POSTGRES_DB") || "gym_rats_test",
  hostname: System.get_env("POSTGRES_HOST") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :gym_rats, GymRatsWeb.Endpoint,
  http: [port: 4002],
  server: false

config :gym_rats, GymRats.Mailer, adapter: Bamboo.TestAdapter

# Print only warnings and errors during test
config :logger, level: :warn

config :joken, default_signer: "secrets secrets are fun let's tell everyone!!!"
