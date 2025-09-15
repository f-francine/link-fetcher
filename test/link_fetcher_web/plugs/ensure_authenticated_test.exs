defmodule LinkFetcherWeb.Plugs.EnsureAuthenticatedTest do
  use LinkFetcherWeb.ConnCase, async: true

  alias LinkFetcherWeb.Plugs.EnsureAuthenticated

  test "allows access when user is authenticated", %{conn: conn} do
    conn = Plug.Test.init_test_session(conn, current_user_id: 123)
    conn = EnsureAuthenticated.call(conn, %{})
    refute conn.halted
  end

  test "redirects and flashes when not authenticated", %{conn: conn} do
    updated_conn =
      Plug.Session.call(
        conn,
        Plug.Session.init(
          store: :cookie,
          secret_key_base: String.duplicate("a", 64),
          key: "_test_key",
          signing_salt: "salt"
        )
      )
      |> fetch_session()
      |> LinkFetcherWeb.Plugs.EnsureAuthenticated.call(%{})

    assert updated_conn.halted
    assert redirected_to(updated_conn) == "/signin"
  end
end
