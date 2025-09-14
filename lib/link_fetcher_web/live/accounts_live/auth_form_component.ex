defmodule LinkFetcherWeb.AccountsLive.AuthFormComponent do
  use LinkFetcherWeb, :live_component

  alias LinkFetcher.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage user records in your database.</:subtitle>
      </.header>

      <form
        action={if @action == :signin, do: "/signin", else: "/signup"}
        method="post"
        id="user-form"
      >
        <label>Email</label>
        <input type="hidden" name="_csrf_token" value={get_csrf_token()} />
        <input type="email" name="email" required />
        <label>Password</label>
        <input type="password" name="password" required />
        <button type="submit">{@title}</button>
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

  # def handle_event("signup", %{"user" => user_params}, socket) do
  #   register_user(socket, socket.assigns.action, user_params)
  # end

  #  def handle_event("signin", %{"user" => user_params}, socket) do
  #   login_user(socket, socket.assigns.action, user_params)
  # end

  # defp register_user(socket, :signup, user_params) do
  #   case Accounts.create_user(user_params) do
  #     {:ok, user} ->
  #       notify_parent({:signed_up, user})

  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "User created successfully")
  #        |> push_patch(to: socket.assigns.patch)}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply, assign(socket, form: to_form(changeset))}
  #   end
  # end

  # defp login_user(socket, :signin, user_params) do
  #   case Accounts.authenticate_user(user_params["email"], user_params["password"]) do
  #     {:ok, user} ->
  #       notify_parent({:signed_in, user})

  #       {:noreply,
  #        socket
  #        |> push_patch(to: socket.assigns.patch)}

  #     {:error, reason} ->
  #       changeset = Accounts.change_user(%LinkFetcher.Accounts.User{})
  #       {:noreply, assign(socket, form: to_form(changeset), error_message: "Invalid email or password")}
  #   end
  # end

  # defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
