defmodule LinkFetcher.Jobs.ScrapeJob do
  use Oban.Worker, queue: :default

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"url" => url, "user_id" => user_id}}) do
    case LinkFetcher.Pages.scrape_and_insert(url, user_id) do
      {:ok, page} ->
        Phoenix.PubSub.broadcast(
          LinkFetcher.PubSub,
          "pages:#{user_id}",
          {:page_scraped, page}
        )

        :ok

      {:error, reason} ->
        Phoenix.PubSub.broadcast(
          LinkFetcher.PubSub,
          "pages:#{user_id}",
          {:scrape_failed, reason}
        )

        :ok
    end
  end
end
