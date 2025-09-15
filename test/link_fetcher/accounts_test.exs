defmodule LinkFetcher.AccountsTest do
  use LinkFetcher.DataCase, async: false

  alias LinkFetcher.Accounts

  describe "users" do
    alias LinkFetcher.Accounts.User

    import LinkFetcher.AccountsFixtures

    test "get_user/1 returns the user with given id" do
      user = user_fixture()

      user_id = user.id

      assert %User{id: ^user_id} = Accounts.get_user(user.id)
    end

    test "get_user/1 returns nil when user not found" do
      assert Accounts.get_user(Ecto.UUID.generate()) == nil
    end

    test "register_user/1 with valid data creates a user" do
      valid_attrs = %{email: "test@example.com", password: "secret123"}

      assert {:ok, %User{} = user} = Accounts.register_user(valid_attrs)

      assert user.email == valid_attrs.email
      assert Bcrypt.verify_pass(valid_attrs.password, user.hashed_password)
    end

    test "register_user/1 returns error if email already exists" do
      valid_attrs = %{email: "zoe@the.cat", password: "secret123"}

      assert {:ok, %User{}} = Accounts.register_user(valid_attrs)
      assert {:error, changeset} = Accounts.register_user(valid_attrs)
      assert %{email: ["has already been taken"]} = errors_on(changeset)
    end

    test "register_user/1 with invalid data returns an error" do
      invalid_attrs = %{email: "invalid_email", password: "1"}

      assert {
              :error,
              %{
                errors: %{
                  email: [
                    "has invalid format"
                  ],
                  password: [
                    "should be at least 6 character(s)"
                  ]
                }
              }
            } == User.cast_and_apply(%User{}, invalid_attrs)
    end

    test "authenticate_user/1 with valid credentials returns the user" do
      user = user_fixture(%{email: "amy@the.cat", password: "321secret"})
      assert {:ok, auth_user} = Accounts.authenticate_user(%User{email: user.email, password: "321secret"})
      IO.inspect(auth_user, label: "Authenticated User")
      IO.inspect(user, label: "Original User")
      assert auth_user.id == user.id
    end

    test "authenticate_user/1 returns error for invalid credential" do
      user = user_fixture(%{email: "zoe@the.cat", password: "secret123"})
      assert {:error, :invalid_credentials} = Accounts.authenticate_user(%User{email: user.email, password: "wrongpassword"})
    end

    test "authenticate_user/1 returns error if user does not exist" do
      assert {:error, :invalid_credentials} = Accounts.authenticate_user(%User{email: "random@email", password: "random_password"})
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
