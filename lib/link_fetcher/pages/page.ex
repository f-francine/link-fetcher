defmodule LinkFetcher.Pages.Page do
  use Ecto.Schema
  import Ecto.Changeset

  @fields ~w(title url user_id)a

  schema "pages" do
    field :title, :string
    field :url, :string
    belongs_to :user, LinkFetcher.Accounts.User, type: :binary_id
    has_many :links, LinkFetcher.Pages.Link

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
