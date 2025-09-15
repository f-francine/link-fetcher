defmodule LinkFetcherWeb.PagesLive.Show do
  use LinkFetcherWeb, :live_view

  alias LinkFetcher.Pages
  alias LinkFetcher.Pages.Page

  require Logger

  @impl true
  def mount(params, session, socket) do
    user = LinkFetcher.Accounts.get_user(session["current_user_id"])

    if authenticated?(user) do
      page = LinkFetcher.Pages.get_page(params["page_id"])

      {:ok,
       socket
       |> assign(:page_title, "Details")
       |> assign(:current_user_id, user.id)
       |> assign(:page, page)}
    else
      {:ok,
       socket
       |> put_flash(:error, "Need to be signed in")
       |> redirect(to: ~p"/signin")}
    end
  end

  @impl true
  def handle_event("show", %{"page_id" => id}, socket) do
    page = Pages.get_page(id)

    {:noreply, socket |> assign(page: page)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    page = Pages.get_page(params["page_id"])

    {:noreply,
      socket
      |> assign(:page_title, "Details")
      |> assign(:page, page)
    }
  end

  defp authenticated?(user), do: if(user == nil, do: false, else: true)
end
