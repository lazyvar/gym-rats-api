defmodule GymRats.Repo.Migrations.CreateChallenges do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:challenges)

    alter table(:challenges) do
      add_if_not_exists(:name, :varchar, null: false)
      add_if_not_exists(:code, :varchar, null: false)
      add_if_not_exists(:profile_picture_url, :varchar)
      add_if_not_exists(:start_date, :utc_datetime_usec, null: false)
      add_if_not_exists(:end_date, :utc_datetime_usec, null: false)
      add_if_not_exists(:time_zone, :varchar, null: false)

      add_if_not_exists(:created_at, :utc_datetime_usec, null: false)
      add_if_not_exists(:updated_at, :utc_datetime_usec, null: false)
    end

    create_if_not_exists unique_index(:challenges, [:code], name: "index_challenges_on_code")
  end
end
