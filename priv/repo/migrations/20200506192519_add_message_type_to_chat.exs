defmodule GymRats.Repo.Migrations.AddMessageTypeToChat do
  use Ecto.Migration

  def change do
    alter table(:chat_messages) do
      add :message_type, :string, default: "text"
    end
  end
end
