defmodule GymRats.Repo.Migrations.CreateMemberships do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:memberships, primary_key: false)

    alter table(:memberships) do
      add_if_not_exists :owner, :boolean, default: false
      add_if_not_exists :gym_rats_user_id, :bigint
      add_if_not_exists :challenge_id, :bigint
    end

    create_if_not_exists index(:memberships, [:gym_rats_user_id], name: "index_memberships_on_gym_rats_user_id")
    create_if_not_exists index(:memberships, [:challenge_id], name: "index_memberships_on_challenge_id")
    create_if_not_exists unique_index(:memberships, [:challenge_id, :gym_rats_user_id], name: "index_memberships_on_challenge_id_and_gym_rats_user_id")
  end
end
