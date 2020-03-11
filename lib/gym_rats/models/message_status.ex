defmodule GymRats.Model.MessageStatus do
  use Ecto.Schema

  import Ecto.Changeset

  schema "user_read_messages" do
    field :read, :boolean, default: false
    field :gym_rats_user_id, :integer
    field :challenge_id, :integer
    field :chat_message_id, :integer

    timestamps(inserted_at: :created_at)
  end

  @doc false
  def changeset(message_status, attrs) do
    message_status
    |> cast(attrs, [:read])
    |> validate_required([:read])
  end
end
