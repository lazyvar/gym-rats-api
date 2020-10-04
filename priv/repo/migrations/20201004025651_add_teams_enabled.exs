defmodule GymRats.Repo.Migrations.AddTeamsEnabled do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add :teams_enabled, :boolean, default: false, null: false
    end
  end
end
