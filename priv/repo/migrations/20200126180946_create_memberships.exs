defmodule GymRats.Repo.Migrations.CreateMemberships do
  use Ecto.Migration

  def change do
    create table(:memberships) do
      add :owner, :boolean, default: false, null: false
      add :gym_rats_user_id, :bigint, null: false
      add :challenge_id, :bigint, null: false

      timestamps(inserted_at: :created_at)
    end

    create index(:memberships, [:gym_rats_user_id])
    create index(:memberships, [:challenge_id])
    create unique_index(:memberships, [:gym_rats_user_id, :challenge_id])
  end
end
