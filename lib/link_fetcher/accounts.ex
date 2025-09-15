defmodule LinkFetcher.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias LinkFetcher.Repo

  alias LinkFetcher.Accounts.User

  @doc """
  Gets a single user.
  """
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Authenticastes an user by email and password.

  Everytime a user logs in, this function is called on
  the controller level to validate credentials and insert
  session data.
  """
  def authenticate_user(%User{} = user) do
    user = Repo.get_by(User, email: user.email)

    cond do
      user && Bcrypt.verify_pass(user.password, user.hashed_password) ->
        {:ok, user}

      user ->
        {:error, :invalid_password}

      true ->
        {:error, :user_not_found}
    end
  end

  @doc """
  Registers an user with email and password.

  Everytime a user signs up, this function is called on
  the controller level to validate credentials and insert
  session data.
  """
  def register_user(%User{} = user) do
    case Repo.insert(user) do
      {:ok, user} -> {:ok, user}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
