defmodule LinkFetcherWeb.Plugs.EnsureAuthenticated do
  import Plug.Conn
  import Phoenix.Controller

  def init(default), do: default

  def call(conn, _default) do
    if get_session(conn, :current_user_id) do
      conn
    else
      conn
      |> fetch_flash()
      |> put_flash(:error, "You must be logged in to access that page.")
      |> redirect(to: "/signin")
      |> halt()
    end
  end
end
