defmodule GymRats.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string, null: false
      add :challenge_id, :bigint, null: false
      add :photo_url, :string

      timestamps()
    end

    create index(:teams, [:challenge_id])
  end
end
