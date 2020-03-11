defmodule GymRats.Repo.Migrations.CreateWorkouts do
  use Ecto.Migration

  def change do
    create table(:workouts) do
      add :gym_rats_user_id, :bigint, null: false
      add :title, :string, null: false
      add :description, :string
      add :photo_url, :string
      add :google_place_id, :string
      add :challenge_id, :integer
      add :duration, :integer
      add :distance, :string
      add :steps, :integer
      add :calories, :integer
      add :points, :integer

      timestamps(inserted_at: :created_at)
    end

    create index(:workouts, [:gym_rats_user_id])
    create index(:workouts, [:challenge_id])
  end
end
