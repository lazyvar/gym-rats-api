defmodule GymRats.Repo.Migrations.AddAppleHealthToWorkout do
  use Ecto.Migration

  def change do
		alter table(:workouts) do
			add :apple_device_name, :string
			add :apple_source_name, :string
			add :apple_workout_uuid, :string
			add :activity_type, :string
		end
  end
end
