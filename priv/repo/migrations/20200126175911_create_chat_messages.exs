defmodule GymRats.Repo.Migrations.CreateChatMessages do
  use Ecto.Migration

  def change do
    create table(:chat_messages) do
      add :content, :string
      add :challenge_id, :bigint, null: false,
      add :gym_rats_user_id, :bigint, null: false,

      timestamps()
    end

    create index(:chat_messages, [:challenge_id])
    create index(:chat_messages, [:gym_rats_user_id])
  end
end
