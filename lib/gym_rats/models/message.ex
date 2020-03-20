defmodule GymRats.Model.Message do
  use Ecto.Schema

  alias GymRats.Model.{Account, Challenge, ChatNotification}

  import Ecto.Changeset

  schema "chat_messages" do
    field :content, :string

    belongs_to :account, Account, foreign_key: :gym_rats_user_id
    belongs_to :challenge, Challenge

    has_many :chat_notifications, ChatNotification

    timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
  end

  @required ~w(content account_id challenge_id)a
  @optional ~w()a

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
  end
end
