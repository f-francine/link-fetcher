defmodule LinkFetcher.Crawler.LinkSpider do
  use Crawly.Spider

  @impl Crawly.Spider
  def base_url(url), do: url

  @impl Crawly.Spider
  def init(url) do
    [
      start_urls: [base_url(url)],
      middlewares: [
        {Crawly.Middlewares.DomainFilter, domains: [URI.parse(url).host]},
        Crawly.Middlewares.UniqueRequest,
        Crawly.Middlewares.UserAgent,
        Crawly.Middlewares.FollowRedirects
      ],
      pipelines: [
        {Crawly.Pipelines.JSONEncoder, extension: "json"},
      ]
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    links =
      document
      |> Floki.find("a") # Find all anchor tags
      |> Enum.map(fn link ->
        %{
          url: Floki.attribute(link, "href") |> List.first(),
          title: Floki.text(link)
        }
      end)

    # Return the extracted links as items
    Enum.map(links, fn link ->
      %{data: link}
    end)
  end
end
