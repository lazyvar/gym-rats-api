defmodule GymRats.Repo.Migrations.CreateTeamMemberships do
  use Ecto.Migration

  def change do
    create table(:team_memberships, primary_key: false) do
      add :team_id, :bigint, null: false, primary_key: true
      add :account_id, :bigint, null: false, primary_key: true

      timestamps()
    end

    create index(:team_memberships, [:team_id])
    create index(:team_memberships, [:account_id])
    create unique_index(:team_memberships, [:team_id, :account_id])
  end
end
