defmodule LinkFetcher.Pages do
  alias LinkFetcher.Repo
  alias LinkFetcher.Pages.Page
  alias LinkFetcher.Pages.Link

  import Ecto.Query, warn: false

  def scrape(url) do
    LinkFetcher.Crawler.crawl(url)
  end

  def list_pages(user_id) do
    Page
    |> where(user_id: ^user_id)
    |> order_by(desc: :inserted_at)
    |> preload(:links)
    |> Repo.all()
  end

  def insert_page(attrs) do
    %Page{}
    |> Page.changeset(attrs)
    |> Repo.insert()
  end

  def insert_links(page, links_attrs) do
    Enum.each(links_attrs, fn link ->
      %Link{}
      |> Link.changeset(Map.put(link, :page_id, page.id))
      |> Repo.insert()
    end)
  end
end
