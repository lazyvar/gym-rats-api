defmodule GymRats.Repo.Migrations.CreateChallenges do
  use Ecto.Migration

  def change do
    create table(:challenges) do
      add :name, :string, null: false
      add :code, :string, null: false
      add :profile_picture_url, :string
      add :start_date, :utc_datetime, null: false
      add :end_date, :utc_datetime, null: false
      add :time_zone, :string, null: false

      timestamps(inserted_at: :created_at)
    end

    create unique_index(:challenges, [:code])
  end
end
