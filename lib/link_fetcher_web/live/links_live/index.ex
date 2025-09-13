defmodule LinkFetcherWeb.LinksLive.Index do
  use LinkFetcherWeb, :live_view

  alias LinkFetcher.Links

  @impl true
  def mount(params, session, socket) do
    IO.inspect(params, label: "Params in LinksLive.Index mount")
    IO.inspect(session, label: "Session in LinksLive.Index mount")
    IO.inspect(socket, label: "Socket  in LinksLive.Index mount")
    IO.inspect("----------------------")
    user = LinkFetcher.Accounts.get_user!(session[:user_id])
    {:ok,
      socket
      |> assign(:page_title, "Links")
      |> assign(:current_user, user)
      |> assign(:links, Links.list_pages(user.id))
    }
  end

  def handle_event("new", %{"url" => url}, socket) do
    r = LinkFetcher.Links.scrape(url)

    {:noreply,
      socket
      |> assign(:links, Links.list_pages(socket.assigns.current_user.id))
    }
  end

  @impl true
  def handle_params(_params, _url, socket) do
    IO.inspect(socket, label: "socket in LinksLive.Index handle_params")
    case socket.assigns.live_action do
      :index ->
        {:noreply,
         socket
         |> assign(:page_title, "Links")
         |> assign(:pages, LinksFetcher.Links.list_pages(user_id: socket.assigns.current_user.id))
        }

      :new ->
        {:noreply,
         socket
         |> assign(:page_title, "New Link")
         |> assign(:pages, %LinkFetcher.Links.Page{})
        }
    end
  end
end
