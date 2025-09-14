defmodule LinkFetcherWeb.HomeLive do
  use LinkFetcherWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       show_form: false,
       form_type: nil,
       changeset: %{}
     ), layout: false}
  end

  @impl true
  def handle_event("show_form", %{"type" => type}, socket) do
    {:noreply, assign(socket, show_form: true, form_type: type)}
  end

  @impl true
  def handle_event("hide_form", _, socket) do
    {:noreply, assign(socket, show_form: false, form_type: nil)}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    if socket.assigns.form_type == "signup" do
      send(self(), {:signup, user_params})
    end

    {:noreply, socket}
  end
end
