defmodule LinkFetcher.PagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LinkFetcher.Pages` context.
  """

  @doc """
  Generate a page.
  """
  def page_fixture(attrs \\ %{}) do
    user = LinkFetcher.AccountsFixtures.user_fixture()

    {:ok, page} =
      attrs
      |> Enum.into(%{
        title: "some title",
        url: "some url",
        user_id: user.id
      })
      |> LinkFetcher.Pages.insert_page()
    page
  end
end
