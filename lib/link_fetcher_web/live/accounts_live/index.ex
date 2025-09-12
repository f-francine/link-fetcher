defmodule LinkFetcherWeb.AccountsLive.Index do
  use LinkFetcherWeb, :live_view

  alias LinkFetcherWeb.AccountsLive.FormComponent
  alias LinkFetcher.Accounts.User

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
    socket |> assign(:user, %LinkFetcher.Accounts.User{})
           |> assign(:page_title, "Welcome")
           |> assign(:current_user, nil)
           |> assign(:live_action, :home)
  }
  end

  @impl true
  @spec handle_info(any(), any()) :: none()
  def handle_info({FormComponent, {event, user}}, socket) when event in [:signed_up, :signed_in] do
    {:noreply,
      socket
      |> assign(:current_user, user)}
      |> push_navigate(to: "/links")
  end

  @impl true
  def handle_params(_params, _url, socket) do
    case socket.assigns.live_action do
      :signup ->
        {:noreply,
         socket
         |> assign(:page_title, "Create an account")
         |> assign(:user, %LinkFetcher.Accounts.User{})
        }

      :signin ->
        {:noreply,
         socket
         |> assign(:page_title, "Log in to your account")
         |> assign(:user, %LinkFetcher.Accounts.User{})
        }

      :home ->
        {:noreply,
         socket
         |> assign(:page_title, "Welcome")
         |> assign(:user, %LinkFetcher.Accounts.User{})
        }
    end
  end
end
