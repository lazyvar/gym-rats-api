defmodule GymRats.Repo.Migrations.CreateWorkouts do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:workouts)

    alter table(:workouts) do
      add_if_not_exists :gym_rats_user_id, :bigint, null: false
      add_if_not_exists :title, :varchar, null: false
      add_if_not_exists :description, :varchar
      add_if_not_exists :photo_url, :varchar
      add_if_not_exists :google_place_id, :varchar
      add_if_not_exists :challenge_id, :bigint
      add_if_not_exists :duration, :integer
      add_if_not_exists :distance, :varchar
      add_if_not_exists :steps, :integer
      add_if_not_exists :calories, :integer
      add_if_not_exists :points, :integer

      add_if_not_exists :created_at, :utc_datetime_usec, null: false
      add_if_not_exists :updated_at, :utc_datetime_usec, null: false
    end

    create_if_not_exists index(:workouts, [:gym_rats_user_id], name: "index_workouts_on_gym_rats_user_id")
    create_if_not_exists index(:workouts, [:challenge_id], name: "index_workouts_on_challenge_id")
  end
end
