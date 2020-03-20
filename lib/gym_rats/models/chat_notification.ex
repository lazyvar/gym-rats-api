defmodule GymRats.Model.ChatNotification do
  use Ecto.Schema

  alias GymRats.Model.{Account, Message}

  import Ecto.Changeset

  schema "chat_notifications" do
    field :seen, :boolean, default: false

    belongs_to :message, Message
    belongs_to :account, Account

    timestamps(inserted_at: :created_at)
  end

  @required ~w(seen message_id account_id)a
  @optional ~w()a

  def changeset(workout, attrs) do
    workout
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
  end
end
