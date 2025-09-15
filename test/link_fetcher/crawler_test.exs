defmodule LinkFetcher.CrawlerTest do
  use ExUnit.Case, async: true

  alias LinkFetcher.Crawler


  @tag :external
  test "crawl/1 returns links and title for a real page" do
    url = "https://elixir-lang.org"
    result = Crawler.crawl(url)

    assert {:ok, %{links: links, title: title}} = result
    assert is_list(links)
    assert is_binary(title)
    assert String.length(title) > 0
  end
end
