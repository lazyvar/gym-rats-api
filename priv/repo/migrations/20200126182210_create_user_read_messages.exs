defmodule GymRats.Repo.Migrations.CreateUserReadMessages do
  use Ecto.Migration

  def change do
    create table(:user_read_messages) do
      add :read, :boolean, default: false, null: false
      add :gym_rats_user_id, :bigint
      add :challenge_id, :bigint
      add :chat_message_id, :bigint

      timestamps()
    end

    create index(:user_read_messages, [:gym_rats_user_id])
    create index(:user_read_messages, [:challenge_id])
    create index(:user_read_messages, [:chat_message_id])
  end
end
