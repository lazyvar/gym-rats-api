defmodule GymRats.Repo.Migrations.CreateWorkoutMedia do
  use Ecto.Migration

  def change do
    create table(:workout_media) do
      add :workout_id, :bigint, null: false
      add :url, :string, null: false
      add :thumbnail_url, :string
      add :medium_type, :string, null: false

      timestamps()
    end

    create index(:workout_media, [:workout_id])
  end
end
