defmodule LinkFetcher.Repo.Migrations.AddLinksTable do
  use Ecto.Migration

  def change do
    create table(:links) do
      add :url, :string
      add :title, :string

      add :page_id, references(:pages, type: :integer)

      timestamps(type: :utc_datetime)
    end
  end
end
