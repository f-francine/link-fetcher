defmodule LinkFetcherWeb.PagesLive.IndexTest do
  use LinkFetcherWeb.ConnCase

  import Phoenix.LiveViewTest
  alias LinkFetcher.Accounts
  alias LinkFetcher.PagesFixtures

  setup %{conn: conn} do
    {:ok, user} = Accounts.register_user(%{email: "test@example.com", password: "secret123"})
    conn = Plug.Test.init_test_session(conn, current_user_id: user.id)
    %{conn: conn, user: user}
  end

  test "renders pages list", ctx do
    page = PagesFixtures.page_fixture(%{user_id: ctx.user.id})

    {:ok, _view, html} = live(ctx.conn, "/pages")
    assert html =~ "Pages"
    assert html =~ page.title
  end

  test "can submit new scrape job", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/pages")
    view |> form("form", %{url: "https://elixir-lang.org"}) |> render_submit()

    assert render(view) =~ "Scrape job started"
  end
end
