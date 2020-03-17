defmodule GymRats.Repo.Migrations.CreateDevices do
  use Ecto.Migration

  def change do
    create table(:devices) do
      add :gym_rats_user_id, :bigint, null: false
      add :token, :string, null: false

      timestamps(inserted_at: :created_at)
    end

    create index(:devices, [:gym_rats_user_id])
    create index(:devices, [:token])
    create index(:devices, [:gym_rats_user_id, :token])
  end
end
