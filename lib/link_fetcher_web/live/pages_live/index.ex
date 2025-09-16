defmodule LinkFetcherWeb.PagesLive.Index do
  use LinkFetcherWeb, :live_view

  alias LinkFetcher.Pages
  alias LinkFetcher.Jobs.ScrapeJob
  alias LinkFetcher.Accounts
  alias LinkFetcher.Accounts.User

  import LinkFetcherWeb.Pagination

  require Logger

  @impl true
  @doc """
  Mounts the LiveView, assigns user and page data, and subscribes to PubSub.
  Redirects to login if user is not found.
  """
  def mount(_params, session, socket) do
    case fetch_user(session) do
      {:ok, user} ->
        page_number = 1
        {pages, total_pages} = Pages.paginated_pages(user.id, page_number)

        if connected?(socket),
          do: Phoenix.PubSub.subscribe(LinkFetcher.PubSub, "pages:#{user.id}")

        {:ok,
         socket
         |> assign(:page_title, "Pages")
         |> assign(:current_user_id, user.id)
         |> assign(:username, user.email)
         |> assign(:pages, pages)
         |> assign(:page_number, page_number)
         |> assign(:total_pages, total_pages)
         |> assign(:status, nil)}

      {:error, reason} ->
        {:ok,
         socket
         |> put_flash(:error, reason)
         |> redirect(to: "/signin")}
    end
  end

  @impl true
  @doc """
  Handles PubSub message when a page is scraped.
  """
  def handle_info({:page_scraped, _}, socket) do
    {pages, total_pages} =
      Pages.paginated_pages(socket.assigns.current_user_id, socket.assigns.page_number)

    {:noreply,
     socket
     |> assign(:pages, pages)
     |> assign(:total_pages, total_pages)
     |> put_flash(:info, "page added successfully!")}
  end

  def handle_info({:scrape_failed, {_reason, err_status}}, socket) do
    {:noreply,
     socket
     |> put_flash(:error, "Failed to scrape page: status #{inspect(err_status)}")
     |> push_patch(to: ~p"/pages")}
  end

  @impl true
  @doc """
  Each time an user clicks the `scrape` button, a `new`
  event is triggered and handled by this function.
  """
  def handle_event("new", %{"url" => url}, socket) do
    user_id = socket.assigns.current_user_id

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
    {pages, total_pages} = Pages.paginated_pages(socket.assigns.current_user_id, page_number)

    {:noreply, assign(socket, pages: pages, page_number: page_number, total_pages: total_pages)}
  end

  @impl true
  @doc """
  Handles URL params and updates assigns accordingly.
  """
  def handle_params(_params, _url, socket) do
    {pages, total_pages} =
      Pages.paginated_pages(socket.assigns.current_user_id, socket.assigns.page_number)

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

  # Private helpers

  defp fetch_user(session) do
    # Because we have already checked for nil in the session plug
    # we can safely assume the current_user_id is present
    case Accounts.get_user(session["current_user_id"]) do
      %User{} = user -> {:ok, user}
      _ -> {:error, "User not found"}
    end
  end
end
