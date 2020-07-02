defmodule GymRats.Repo.Migrations.AddNotificationSettings do
  use Ecto.Migration

  def change do
    alter table(:gym_rats_users) do
      add :workout_notifications_enabled, :boolean, default: false, null: false
      add :comment_notifications_enabled, :boolean, default: false, null: false
      add :chat_message_notifications_enabled, :boolean, default: false, null: false
		end
  end
end
