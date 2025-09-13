# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :link_fetcher,
  ecto_repos: [LinkFetcher.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :link_fetcher, LinkFetcherWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: LinkFetcherWeb.ErrorHTML, json: LinkFetcherWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: LinkFetcher.PubSub,
  live_view: [signing_salt: "qRjK7PRi"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  link_fetcher: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  link_fetcher: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configures Crawly
config :crawly,
  closespider_timeout: 10, # Stop after 10 seconds
  concurrent_requests_per_domain: 10,
  closespider_itemcount: 100 # Stop after collecting 100 items

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
