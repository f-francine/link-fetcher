defmodule LinkFetcher.Crawler do
  require Logger

  def crawl(url) do
    with {:fetch, %{status_code: 200, body: body}} <- {:fetch, Crawly.fetch(url)},
         {:ok, document} <- Floki.parse_document(body) do
      {:ok, %{links: extract_page_info(document), title: extract_domain_page_title(document)}}
    else
      {:fetch, %{status_code: status}} ->
        Logger.error("Failed to fetch page. Status #{status} was returned")
        {:error, :fetch_page_failed}
      e ->
        Logger.error("Unexpected error when crawling the website", error: e)
        e
    end
  end

  defp extract_page_info(document) do
    document
    # Find all anchor tags
    |> Floki.find("a")
    |> Enum.map(fn link ->
      %{
        url: link |> Floki.attribute("href") |> List.first(),
        title: Floki.text(link)
      }
    end)
  end

  defp extract_domain_page_title(document) do
    [{_, _, [title_txt]}] = Floki.find(document, "title")

    title_txt
  end
end
