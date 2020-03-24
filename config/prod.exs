use Mix.Config

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :gym_rats, GymRatsWeb.Endpoint,
  http: [
    port: System.get_env("PORT") || "4000",
    transport_options: [socket_opts: [:inet6]]
  ],
  url: [
    scheme: "https",
    host: System.get_env("HOST") || raise("HOST missing"),
    port: 443
  ],
  server: true,
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  secret_key_base: secret_key_base

config :gym_rats, GymRats.Repo,
  ssl: true,
  username: System.get_env("DATABASE_USERNAME") || raise("DATABASE_USERNAME is missing"),
  password: System.get_env("DATABASE_PASSWORD") || raise("DATABASE_PASSWORD is missing"),
  database: System.get_env("DATABASE_DATABASE") || raise("DATABASE_DATABASE is missing"),
  hostname: System.get_env("DATABASE_HOSTNAME") || raise("DATABASE_HOSTNAME is missing"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

config :logger, level: :info

config :sentry,
  dsn: System.get_env("SENTRY_DSN"),
  included_environments: [:prod],
  environment_name: :prod

config :pigeon, :apns,
  apns_default: %{
    key: System.get_env("APNS_TOKEN"),
    key_identifier: "FW985G67H6",
    team_id: "ANX28TKVYJ",
    mode: System.get_env("APNS_MODE") || :dev
  }

config :gym_rats, GymRats.Mailer,
  adapter: Bamboo.MailgunAdapter,
  api_key: {:system, "MAILGUN_API_KEY"},
  domain: {:system, "MAILGUN_DOMAIN"}

config :joken,
  default_signer: System.get_env("SIGNING_SECRET") || raise("SIGNING_SECRET is missing")
