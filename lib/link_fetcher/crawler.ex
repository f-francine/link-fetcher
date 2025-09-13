defmodule LinkFetcher.Crawler do
  alias LinkFetcher.Crawler.LinkSpider

  def crawl(url) do
    Crawly.Engine.start_spider(LinkFetcher.Crawler.LinkSpider, url)
  end

  @doc """
  Gets the current crawling status.
  """
  def get_status do
    Crawly.Engine.get_spider_status(LinkFetcher.Crawler.LinkSpider)
  end
end
