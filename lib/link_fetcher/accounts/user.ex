defmodule LinkFetcher.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields ~w(email password)a

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}
  @foreign_key_type :binary_id
  schema "users" do
    field :email, :string
    field :password, :string
    field :hashed_password, :string

    has_many :pages, LinkFetcher.Pages.Page

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user \\ %__MODULE__{}, attrs) do
    user
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_length(:password, min: 6)
    |> hash_password()
  end

  defp hash_password(changeset) do
    case get_change(changeset, :password) do
      nil -> add_error(changeset, :hashed_password, "failed to validate password")
      password -> put_change(changeset, :hashed_password, Bcrypt.hash_pwd_salt(password))
    end
  end

  def cast_and_apply(user \\ %__MODULE__{}, attrs) do
    casted_attrs = changeset(user, attrs)

    case apply_changes(casted_attrs) do
      %__MODULE__{} = user -> {:ok, user}
      err -> {:error, err}
    end
  end
end
