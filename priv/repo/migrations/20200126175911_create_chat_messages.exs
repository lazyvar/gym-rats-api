defmodule GymRats.Repo.Migrations.CreateChatMessages do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:chat_messages)

    alter table(:chat_messages) do
      add_if_not_exists :content, :varchar
      add_if_not_exists :challenge_id, :bigint
      add_if_not_exists :gym_rats_user_id, :bigint

      add_if_not_exists :created_at, :utc_datetime_usec, null: false
      add_if_not_exists :updated_at, :utc_datetime_usec, null: false
    end

    create_if_not_exists index(:chat_messages, [:challenge_id], name: "index_chat_messages_on_challenge_id")
    create_if_not_exists index(:chat_messages, [:gym_rats_user_id], name: "index_chat_messages_on_gym_rats_user_id")
  end
end
