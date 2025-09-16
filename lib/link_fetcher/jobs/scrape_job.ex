defmodule LinkFetcher.Jobs.ScrapeJob do
  @moduledoc """
  This module defines an Oban worker for scraping web pages.
  It calls Crawly to fetch the content of a given URL, extracts links, and stores
  them in the database.
  """

  use Oban.Worker, queue: :default

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"url" => url, "user_id" => user_id}}) do
    case LinkFetcher.Pages.scrape_and_insert(url, user_id) do
      {:ok, page} ->
        notify_parent(user_id, {:page_scraped, page})

      {:error, reason} ->
        notify_parent(user_id, {:scrape_failed, reason})
    end
  end

  defp notify_parent(user_id, message) do
    Phoenix.PubSub.broadcast(
      LinkFetcher.PubSub,
      "pages:#{user_id}",
      message
    )
  end
end
