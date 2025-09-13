defmodule LinkFetcher.Links do
  alias LinkFetcher.Repo
  alias LinkFetcher.Links.Page

  import Ecto.Query, warn: false

  def scrape(url) do
    r = LinkFetcher.Crawler.crawl(url)
    IO.inspect(r, label: "Crawl Result")
    r
  end

  def list_pages(user_id) do
    Repo.all(Page |> where(user_id: ^user_id) |> order_by(desc: :inserted_at))
  end
end
