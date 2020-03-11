defmodule GymRats.Repo.Migrations.CreateGymRatsUsers do
  use Ecto.Migration

  def change do
    create table(:gym_rats_users) do
      add :full_name, :string, null: false
      add :email, :string, null: false
      add :profile_picture_url, :string
      add :password_digest, :string, null: false
      add :reset_password_token, :string
      add :reset_password_token_expiration, :utc_datetime

      timestamps(inserted_at: :created_at)
    end

    create unique_index(:gym_rats_users, [:email])
  end
end
