defmodule LinkFetcher.Pages do
  alias LinkFetcher.Repo
  alias LinkFetcher.Pages.Page
  alias LinkFetcher.Pages.Link

  import Ecto.Query, warn: false

  @doc "Fetches a given url and returns all links found on the page"
  def scrape(url), do: LinkFetcher.Crawler.crawl(url)

  @doc "Lists all pages for a given user, sorted by most recent"
  def list_pages(user_id) do
    Page
    |> where(user_id: ^user_id)
    |> order_by(desc: :inserted_at)
    |> preload(:links)
    |> Repo.all()
  end

  @spec insert_page(
          :invalid
          | %{optional(:__struct__) => none(), optional(atom() | binary()) => any()}
        ) :: any()
  @doc "Inserts a new page with the given attributes"
  def insert_page(attrs) do
    %Page{}
    |> Page.changeset(attrs)
    |> Repo.insert()
  end

  def scrape_and_insert(url, user_id) do
    with {:ok, %{links: links, title: title}} <- scrape(url),
         {:ok, page} <- insert_page(%{url: url, title: title, user_id: user_id}) do
      insert_links(page, links)
      {:ok, page}
    else
      error -> error
    end
  end

  @doc "Inserts multiple links associated with a given page"
  def insert_links(page, links_attrs) do
    Enum.each(links_attrs, fn link ->
      %Link{}
      |> Link.changeset(Map.put(link, :page_id, page.id))
      |> Repo.insert()
    end)
  end

  @doc "Returns paginated links for a given page"
  def paginated_links(page_id, page_number, page_size \\ 5) do
    query =
      from l in Link,
        where: l.page_id == ^page_id,
        order_by: [desc: l.inserted_at]

    paginate(query, page_size, page_number)
  end

  @doc "Returns paginated pages for a given user"
  def paginated_pages(user_id, page_number, page_size \\ 10) do
    query =
      from p in Page,
        where: p.user_id == ^user_id,
        preload: [:links],
        order_by: [desc: p.inserted_at]

    paginate(query, page_size, page_number)
  end

  defp paginate(query, page_size, page_number) do
    total_items = Repo.aggregate(query, :count, :id)

    pages =
      query
      |> limit(^page_size)
      |> offset(^(page_size * (page_number - 1)))
      |> Repo.all()

    {pages, calculate_total_pages(total_items, page_size)}
  end

  defp calculate_total_pages(total_items, page_size) do
    total_pages = div(total_items, page_size)
    if rem(total_items, page_size) > 0, do: total_pages + 1, else: total_pages
  end

  def get_page(id) do
    Repo.get(Page, id)
    |> Repo.preload(:links)
  end
end
