defmodule GymRats.Repo.Migrations.AddSubscribedToAccounts do
  use Ecto.Migration

  def change do
    alter table(:gym_rats_users) do
      add :subscribed, :boolean, null: false, default: true
    end
  end
end
