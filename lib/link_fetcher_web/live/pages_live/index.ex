defmodule LinkFetcherWeb.PagesLive.Index do
  use LinkFetcherWeb, :live_view

  alias LinkFetcher.Pages
  alias LinkFetcher.Jobs.ScrapeJob

  import LinkFetcherWeb.Pagination

  require Logger

  @impl true
  def mount(_params, session, socket) do

    IO.inspect(session["current_user_id"], label: "session in pages live")
    user = LinkFetcher.Accounts.get_user(session["current_user_id"])

    page_number = 1

    {pages, total_pages} = LinkFetcher.Pages.paginated_pages(user.id, page_number)

    if connected?(socket), do: Phoenix.PubSub.subscribe(LinkFetcher.PubSub, "pages:#{user.id}")

    {:ok,
     socket
     |> assign(:page_title, "Pages")
     |> assign(:current_user_id, user.id)
     |> assign(:pages, pages)
     |> assign(:page_number, page_number)
     |> assign(:total_pages, total_pages)
     |> assign(:status, nil)}
  end

  @impl true
  def handle_info({:page_scraped, _}, socket) do
    {pages, total_pages} =
      Pages.paginated_pages(socket.assigns.current_user_id, socket.assigns.page_number)

    {:noreply,
     socket
     |> assign(:pages, pages)
     |> assign(:total_pages, total_pages)
     |> put_flash(:info, "page added successfully!")}
  end

  @impl true
  def handle_info({:scrape_failed, {_reason, err_status}}, socket) do
    {:noreply,
     socket
     |> put_flash(:error, "Failed to scrape page: status #{inspect(err_status)}")
     |> push_patch(to: ~p"/pages")}
  end

  @impl true
  def handle_event("new", %{"url" => url}, socket) do
    user_id = socket.assigns.current_user_id

    # Enqueue the background job
    case Oban.insert(ScrapeJob.new(%{url: url, user_id: user_id}), max_attempts: 1) do
      {:ok, _job} ->
        {:noreply,
         socket
         |> put_flash(:info, "Scrape job started! You will see results when it's done.")
         |> push_patch(to: ~p"/pages")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Failed to start scrape job: #{inspect(reason)}")}
    end
  end

  @impl true
  def handle_event("paginate", %{"page" => page}, socket) do
    page_number = String.to_integer(page)

    {pages, total_pages} =
      Pages.paginated_pages(socket.assigns.current_user_id, page_number)

    {:noreply, assign(socket, pages: pages, page_number: page_number, total_pages: total_pages)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {pages, total_pages} =
      LinkFetcher.Pages.paginated_pages(
        socket.assigns.current_user_id,
        socket.assigns.page_number
      )

    case socket.assigns.live_action do
      :index ->
        {:noreply,
         socket
         |> assign(:page_title, "Links")
         |> assign(:pages, pages)
         |> assign(:total_pages, total_pages)}

      :new ->
        {:noreply,
         socket
         |> assign(:page_title, "New Link")
         |> assign(:pages, %LinkFetcher.Pages.Page{})
         |> assign(:status, "processing")
         |> put_flash(:info, "Processing the page...")}
    end
  end
end
