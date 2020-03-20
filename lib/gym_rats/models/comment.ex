defmodule GymRats.Model.Comment do
  use Ecto.Schema

  alias GymRats.Model.{Account, Workout, Comment}

  import Ecto.Changeset

  schema "comments" do
    field :content, :string

    belongs_to :account, Account, foreign_key: :gym_rats_user_id
    belongs_to :workout, Workout
    has_many :comments, Comment

    timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
  end

  @required ~w(content account_id workout_id)a
  @optional ~w()a

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
  end
end
