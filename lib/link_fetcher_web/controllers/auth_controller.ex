defmodule LinkFetcherWeb.AuthController do
  use LinkFetcherWeb, :controller

  require Logger

  alias LinkFetcher.Accounts.User

  @doc """
  Handles user signin by authenticating the provided credentials.
  On success, sets the session and redirects to the pages path.
  On failure, sets an error flash message and redirects to the sign-in page.
  """
  def signin(conn, params) do
    with {:ok, input} <- User.cast_and_apply(params),
         {:ok, user} <- LinkFetcher.Accounts.authenticate_user(input) do
      conn
      |> put_session(:current_user_id, user.id)
      |> redirect(to: "/pages")
    else
      {:error, reason} ->
        Logger.error("Sign-in failed: #{inspect(reason)}")

        conn
        |> put_flash(:error, "Invalid credentials")
        |> redirect(to: "/signin")
    end
  end

  @doc """
  Handles user signup by registering a new user with the provided parameters.
  On success, logs in the user and redirects to the pages path.
  On failure, sets an error flash message and redirects to the signup page.
  """
  def signup(conn, params) do
    case LinkFetcher.Accounts.register_user(params) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> redirect(to: "/pages")

      {:error, reason} ->
        Logger.error("User registration failed: #{inspect(reason)}")

        conn
        |> put_flash(:error, "Failed to register")
        |> redirect(to: "/signup")
    end
  end
end
