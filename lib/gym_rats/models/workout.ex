defmodule GymRats.Model.Workout do
  use Ecto.Schema
  import Ecto.Changeset

  alias GymRats.Model.{Account, Challenge}

  schema "workouts" do
    field :calories, :integer
    field :description, :string
    field :distance, :string
    field :duration, :integer
    field :google_place_id, :string
    field :photo_url, :string
    field :points, :integer
    field :steps, :integer
    field :title, :string
    field :apple_device_name, :string
    field :apple_source_name, :string
    field :apple_workout_uuid, :string
    field :activity_type, :string

    belongs_to :account, Account, foreign_key: :gym_rats_user_id
    belongs_to :challenge, Challenge

    timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
  end

  @required ~w(gym_rats_user_id challenge_id title)a
  @optional ~w(
    steps points steps calories description distance duration google_place_id 
    photo_url apple_device_name apple_source_name apple_workout_uuid activity_type
  )a

  def changeset(workout, attrs) do
    workout
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> validate_inclusion(:activity_type, [
      "walking",
      "running",
      "cycling",
      "hiit",
      "yoga",
      "hiking",
      "other"
    ])
  end
end
