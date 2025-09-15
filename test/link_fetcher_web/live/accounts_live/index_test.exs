defmodule LinkFetcherWeb.AccountsLive.IndexTest do
  use LinkFetcherWeb.ConnCase

  import Phoenix.LiveViewTest

  test "renders signin and signup forms", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/signup")
    assert has_element?(view, "form#user-form")

    {:ok, view, _html} = live(conn, "/signin")
    assert has_element?(view, "form#user-form")
  end

  test "shows error on invalid signup", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/signup")
    view |> form("#user-validate-form", user: %{email: "bad", password: "123"}) |> render_change()

    assert render(view) =~ "must have the @ symbol"
    assert render(view) =~ "must have at least 6 characters"
  end
end
