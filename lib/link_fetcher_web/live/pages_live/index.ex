defmodule LinkFetcherWeb.PagesLive.Index do
  use LinkFetcherWeb, :live_view

  alias LinkFetcher.Pages
  alias LinkFetcher.Pages.Page

  require Logger

  @impl true
  def mount(_params, session, socket) do
    user = LinkFetcher.Accounts.get_user(session["current_user_id"])

    if authenticated?(user) do
      page_number = 1

      {pages, total_pages} = LinkFetcher.Pages.paginated_pages(user.id, page_number)

      {:ok,
       socket
       |> assign(:page_title, "Pages")
       |> assign(:current_user_id, user.id)
       |> assign(:pages, pages)
       |> assign(:page_number, page_number)
       |> assign(:total_pages, total_pages)}
    else
      {:ok,
       socket
       |> put_flash(:error, "Need to be signed in")
       |> redirect(to: ~p"/signin")}
    end
  end

  defp authenticated?(user), do: if(user == nil, do: false, else: true)

  @impl true
  def handle_event("new", %{"url" => url}, socket) do
    case crawl(url, socket.assigns.current_user_id) do
      :ok ->
         {pages, total_pages} = Pages.paginated_pages(socket.assigns.current_user_id, socket.assigns.page_number)

        {:noreply,
         socket
         |> assign(:pages, pages)
         |> assign(:total_pages, total_pages)}

      {:error, :fetch_page_failed} ->
        {:noreply,
         socket
         |> put_flash(:error, "failed to fetch web site")}

      _error ->
        {:noreply,
         socket
         |> put_flash(:error, "unexpected error when crawling the website")}
    end
  end

  @impl true
  def handle_event("paginate", %{"page" => page}, socket) do
    page_number = String.to_integer(page)

    {pages, total_pages} =
      Pages.paginated_pages(socket.assigns.current_user_id, page_number)

    {:noreply, assign(socket, pages: pages, page_number: page_number, total_pages: total_pages)}
  end

  defp crawl(url, user_id) do
    case LinkFetcher.Crawler.crawl(url) do
      {:ok, %{links: links, title: title}} ->
        insert_result(user_id, links, url, title)

      error ->
        error
    end
  end

  defp insert_result(user_id, results, domain_url, domain_title) do
    with {:ok, %Page{} = page} <-
           LinkFetcher.Pages.insert_page(%{url: domain_url, title: domain_title, user_id: user_id}),
         :ok <- LinkFetcher.Pages.insert_links(page, results) do
      :ok
    else
      e ->
        Logger.error("Error when inserting page attrs", error: e)
        e
    end
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {pages, total_pages} = LinkFetcher.Pages.paginated_pages(socket.assigns.current_user_id, socket.assigns.page_number)

    case socket.assigns.live_action do
      :index ->
        {:noreply,
         socket
         |> assign(:page_title, "Links")
         |> assign(:pages, pages)
         |> assign(:total_pages, total_pages)
        }

      :new ->
        {:noreply,
         socket
         |> assign(:page_title, "New Link")
         |> assign(:pages, %LinkFetcher.Pages.Page{})}

    end
  end
end
