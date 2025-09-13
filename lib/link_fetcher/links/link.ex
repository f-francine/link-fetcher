defmodule LinkFetcher.Links.Link do
  use Ecto.Schema
  import Ecto.Changeset

  @fields ~w(url title)a

  schema "links" do
    field :url, :string
    field :title, :string
    belongs_to :pages, LinkFetcher.Links.Page

    timestamps()
  end

  @doc false
  def changeset(link, attrs) do
    link
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
