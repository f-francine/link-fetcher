defmodule LinkFetcher.Repo do
  use Ecto.Repo,
    otp_app: :link_fetcher,
    adapter: Ecto.Adapters.Postgres
end
