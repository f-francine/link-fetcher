defmodule LinkFetcher.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LinkFetcher.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    user_attrs =
      attrs
      |> Enum.into(%{
        email: "zoe@the.cat",
        password: "somepassword"
      })

    {:ok, user} = LinkFetcher.Accounts.register_user(user_attrs)
    user
  end
end
