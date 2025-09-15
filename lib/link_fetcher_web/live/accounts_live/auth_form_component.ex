defmodule LinkFetcherWeb.AccountsLive.AuthFormComponent do
  @moduledoc """
  Component responsible for rendering the signup/signin form and handling its validation.

  The sign in and signup actions are performed via standard HTML form submissions to the AuthController,
  while the LiveComponent handles real-time validation of the form inputs.
  """
  use LinkFetcherWeb, :live_component

  alias LinkFetcher.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>
      
    <!-- LiveView form for validation only -->
      <.form
        for={@form}
        id="user-validate-form"
        phx-change="validate"
        phx-target={@myself}
        autocomplete="off"
      >
        <div class="mb-4">
          <label class="block font-semibold mb-1">Email</label>
          <input
            type="email"
            name="user[email]"
            value={@form[:email].value}
            required
            class="w-full border rounded px-3 py-2"
          />
          <div class="text-xs text-gray-500 mt-1">must have the @ symbol</div>
          <%= if @form[:email].errors != [] do %>
            <span class="text-red-500 text-xs">
              {Enum.map(@form[:email].errors, fn {msg, _opts} -> msg end) |> Enum.join(", ")}
            </span>
          <% end %>
        </div>
        <div class="mb-4">
          <label class="block font-semibold mb-1">Password</label>
          <input
            type="password"
            name="user[password]"
            value={@form[:password].value}
            required
            class="w-full border rounded px-3 py-2"
          />
          <div class="text-xs text-gray-500 mt-1">must have at least 6 characters</div>
          <%= if @form[:password].errors != [] do %>
            <span class="text-red-500 text-xs">
              {Enum.map(@form[:password].errors, fn {msg, _opts} -> msg end) |> Enum.join(", ")}
            </span>
          <% end %>
        </div>
      </.form>
      
    <!-- Regular HTML form for submission -->
      <form
        action={if @action == :signin, do: "/signin", else: "/signup"}
        method="post"
        id="user-form"
        autocomplete="off"
      >
        <input type="hidden" name="_csrf_token" value={get_csrf_token()} />
        <input type="hidden" name="email" value={@form[:email].value} />
        <input type="hidden" name="password" value={@form[:password].value} />
        <div class="flex p-4 justify-center bg-purple-600 text-white rounded font-bold">
          <button
            type="submit"
            disabled={!@form.source.valid?}
            class={"#{unless @form.source.valid?, do: "opacity-50 cursor-not-allowed"}"}
          >
            {@title}
          </button>
        </div>
      </form>
    </div>
    """
  end

  @impl true
  def update(%{user: user} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Accounts.change_user(user))
     end)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user(socket.assigns.user, user_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end
end
