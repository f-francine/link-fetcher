defmodule LinkFetcherWeb.PagesLive.Show do
  use LinkFetcherWeb, :live_view

  alias LinkFetcher.Pages

  import LinkFetcherWeb.Pagination

  require Logger

  @impl true
  def mount(params, session, socket) do
    user = LinkFetcher.Accounts.get_user(session["current_user_id"])

    if authenticated?(user) do
      page_number = 1
      {paginated_links, total_pages} = Pages.paginated_links(params["page_id"], page_number)

      {:ok,
       socket
       |> assign(:page_title, "Details")
       |> assign(:current_user_id, user.id)
       |> assign(:links, paginated_links)
       |> assign(:total_pages, total_pages)
       |> assign(:page_number, page_number)}
    else
      {:ok,
       socket
       |> put_flash(:error, "Need to be signed in")
       |> redirect(to: ~p"/signin")}
    end
  end

  # @impl true
  # def handle_event("show", %{"page_id" => id}, socket) do
  #   page = Pages.get_page(id)

  #   {:noreply, socket |> assign(links: page)}
  # end

  @impl true
  def handle_event("paginate", %{"page" => page}, socket) do
    page_number = String.to_integer(page)
    {paginated_links, total_pages} = Pages.paginated_links(socket.assigns.page.id, page_number)

    {:noreply,
     socket
     |> assign(links: paginated_links)
     |> assign(:total_pages, total_pages)
     |> assign(:page_number, page_number)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    page = Pages.get_page(params["page_id"])

    {:noreply,
     socket
     |> assign(:page_title, "Details")
     |> assign(:page, page)}
  end

  defp authenticated?(user), do: if(user == nil, do: false, else: true)
end
