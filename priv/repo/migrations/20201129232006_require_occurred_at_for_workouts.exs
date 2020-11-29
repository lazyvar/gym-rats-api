defmodule GymRats.Repo.Migrations.RequireOccurredAtForWorkouts do
  use Ecto.Migration

  def change do
    alter table(:workouts) do
      modify :occurred_at, :utc_datetime_usec, null: false
    end
  end
end
