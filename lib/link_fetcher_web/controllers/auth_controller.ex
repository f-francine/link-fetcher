defmodule LinkFetcherWeb.AuthController do
  use LinkFetcherWeb, :controller

  alias LinkFetcher.Accounts.User

  def signin(conn, params) do
    with {:ok, input} <- User.cast_and_apply(params),
         {:ok, user} <- LinkFetcher.Accounts.authenticate_user(input) do
      conn
      |> put_session(:current_user_id, user.id)
      |> redirect(to: "/pages")
    else
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid credentials")
        |> redirect(to: "/signin")
    end
  end

  def signup(conn, params) do
    with {:ok, input} <- User.cast_and_apply(params),
         {:ok, user} <- LinkFetcher.Accounts.register_user(input) do
      conn
      |> put_session(:current_user_id, user.id)
      |> redirect(to: "/pages")
    else
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Failed to register")
        |> redirect(to: "/signup")
    end
  end
end
