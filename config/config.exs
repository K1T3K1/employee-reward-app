# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :employee_reward_app,
  ecto_repos: [EmployeeRewardApp.Repo]

# Guardian module config, token authentication lib
config :employee_reward_app, EmployeeRewardApp.Guardian,
  issuer: "EmployeeRewardApp.#{Mix.env}",
  ttl: {30, :days},
  verify_issuer: true,
  secret_key: {:system, "SECRET_KEY_BASE"}

  config :tailwind, version: "3.2.4", default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :employee_reward_app, EmployeeRewardApp.AuthAccessPipeline,
  module: EmployeeRewardApp.Guardian,
  error_handler: EmployeeRewardApp.AuthErrorHandler

config :employee_reward_app, EmployeeRewardApp.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: {:system, "MAILGUN_SMTP_SERVER"}
  hostname: {:system, "MAILGUN_DOMAIN"}
  port: 587,
  username: {:system, "MAILGUN_SMTP_LOGIN"}, # or {:system, "SMTP_USERNAME"}
  password: {:system, "MAILGUN_SMTP_PASSWORD"}, # or {:system, "SMTP_PASSWORD"}
  tls: :if_available, # can be `:always` or `:never`
  allowed_tls_versions: [:"tlsv1", :"tlsv1.1", :"tlsv1.2"], # or {:system, "ALLOWED_TLS_VERSIONS"} w/ comma separated values (e.g. "tlsv1.1,tlsv1.2")
  tls_log_level: :error,
  tls_verify: :verify_peer, # optional, can be `:verify_peer` or `:verify_none`
  tls_cacertfile: "/somewhere/on/disk", # optional, path to the ca truststore
  tls_cacerts: "…", # optional, DER-encoded trusted certificates
  tls_depth: 3, # optional, tls certificate chain depth
  tls_verify_fun: {&:ssl_verify_hostname.verify_fun/3, check_hostname: "example.com"}, # optional, tls verification function
  ssl: false, # can be `true`
  retries: 1,
  no_mx_lookups: false, # can be `true`
  auth: :if_available # can be `:always`. If your smtp relay requires authentication set it to `:always`.

# Configures the endpoint
config :employee_reward_app, EmployeeRewardAppWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: EmployeeRewardAppWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: EmployeeRewardApp.PubSub,
  live_view: [signing_salt: "Y0Yj+llD"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :employee_reward_app, EmployeeRewardApp.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
