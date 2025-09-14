defmodule LinkFetcher.Repo.Migrations.AddPagesTable do
  use Ecto.Migration

  def change do
    create table(:pages) do
      add :url, :string
      add :title, :string

      add :user_id, references(:users, type: :binary_id)

      timestamps(type: :utc_datetime)
    end
  end
end
