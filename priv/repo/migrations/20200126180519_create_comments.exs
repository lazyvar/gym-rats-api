defmodule GymRats.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :content, :string
      add :workout_id, :bigint, null: false
      add :gym_rats_user_id, :bigint, null: false

      timestamps()
    end

    create index(:comments, [:workout_id])
    create index(:comments, [:gym_rats_user_id])
  end
end
