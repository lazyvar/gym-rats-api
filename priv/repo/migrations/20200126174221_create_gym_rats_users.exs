defmodule GymRats.Repo.Migrations.CreateGymRatsUsers do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:gym_rats_users)

    alter table(:gym_rats_users) do
      add_if_not_exists :full_name, :varchar, null: false
      add_if_not_exists :email, :varchar, null: false
      add_if_not_exists :profile_picture_url, :varchar
      add_if_not_exists :password_digest, :varchar, null: false
      add_if_not_exists :reset_password_token, :varchar
      add_if_not_exists :reset_password_token_expiration, :utc_datetime_usec
      
      add_if_not_exists :created_at, :utc_datetime_usec, null: false
      add_if_not_exists :updated_at, :utc_datetime_usec, null: false
    end

    create_if_not_exists unique_index(:gym_rats_users, [:email], name: "index_gym_rats_users_on_email")
    create_if_not_exists unique_index(:gym_rats_users, [:reset_password_token], name: "index_gym_rats_users_on_reset_password_token")
  end
end
