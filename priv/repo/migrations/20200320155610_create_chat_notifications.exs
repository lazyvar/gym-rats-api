defmodule GymRats.Repo.Migrations.CreateChatNotifications do
  use Ecto.Migration

  def change do
    create table(:chat_notifications) do
      add :seen, :boolean, default: false, null: false
      add :account_id, :integer, null: false
      add :message_id, :integer, null: false

      timestamps(inserted_at: :created_at)
    end

    create index(:chat_notifications, [:account_id])
    create index(:chat_notifications, [:message_id])
  end
end
