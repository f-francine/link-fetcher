defmodule LinkFetcher.PagesTest do
  use LinkFetcher.DataCase, async: true

  alias LinkFetcher.Pages
  alias LinkFetcher.Pages.Page
  alias LinkFetcher.AccountsFixtures

  describe "insert_page/1 and get_page/1" do
    test "inserts and fetches a page" do
      user = AccountsFixtures.user_fixture()

      attrs = %{url: "https://elixir-lang.org", title: "Elixir", user_id: user.id}

      assert {:ok, %Page{} = page} = Pages.insert_page(attrs)
      assert page.url == "https://elixir-lang.org"
      assert Pages.get_page(page.id).id == page.id
    end
  end

  describe "insert_links/2" do
    test "inserts links for a page" do
      user = AccountsFixtures.user_fixture()

      page_attrs = %{url: "https://elixir-lang.org", title: "Elixir", user_id: user.id}
      {:ok, page} = Pages.insert_page(page_attrs)
      links = [
        %{url: "https://hex.pm", title: "Hex"},
        %{url: "https://phoenixframework.org", title: "Phoenix"}]

      assert :ok = Pages.insert_links(page, links)

      page = Pages.get_page(page.id)

      assert Enum.any?(page.links, &(&1.url == "https://hex.pm"))
      assert Enum.any?(page.links, &(&1.url == "https://phoenixframework.org"))
    end
  end
end
