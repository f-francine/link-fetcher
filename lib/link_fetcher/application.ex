defmodule LinkFetcher.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LinkFetcherWeb.Telemetry,
      LinkFetcher.Repo,
      {DNSCluster, query: Application.get_env(:link_fetcher, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: LinkFetcher.PubSub},
      # Start a worker by calling: LinkFetcher.Worker.start_link(arg)
      # {LinkFetcher.Worker, arg},
      # Start to serve requests, typically the last entry
      {Oban, Application.fetch_env!(:link_fetcher, Oban)},
      LinkFetcherWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LinkFetcher.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LinkFetcherWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
