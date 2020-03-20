defmodule GymRats.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:comments)

    alter table(:comments) do
      add_if_not_exists :content, :varchar
      add_if_not_exists :gym_rats_user_id, :bigint
      add_if_not_exists :workout_id, :bigint

      add_if_not_exists :created_at, :utc_datetime_usec, null: false
      add_if_not_exists :updated_at, :utc_datetime_usec, null: false
    end

    create_if_not_exists index(:comments, [:workout_id], name: "index_comments_on_workout_id")
    create_if_not_exists index(:comments, [:gym_rats_user_id], name: "index_comments_on_gym_rats_user_id")
  end
end
