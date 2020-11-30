defmodule GymRats.Repo.Migrations.AddOccurredAtToWorkouts do
  use Ecto.Migration

  def change do
    alter table(:workouts) do
      add :occurred_at, :utc_datetime_usec
    end
  end
end
