defmodule GymRats.Model.Workout do
  use Ecto.Schema

  import Ecto.Changeset

  alias GymRats.Model.{Account, Challenge, WorkoutMedium}

  schema "workouts" do
    field :occurred_at, :utc_datetime_usec
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

    has_many :media, WorkoutMedium

    timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
  end

  @required ~w(gym_rats_user_id challenge_id title)a

  @optional ~w(
    steps points steps calories description distance duration google_place_id occurred_at
    photo_url apple_device_name apple_source_name apple_workout_uuid activity_type
  )a

  @activity_types ~w(
    walking running cycling hiit yoga hiking baseketball climbing cross_training
    dance elliptical functional_strength_training traditional_strength_training
    core_training swimming volleyball rowing stairs cooldown steps other
  )

  def changeset(workout, attrs) do
    workout
    |> cast(attrs, @required ++ @optional)
    |> add_occurred_at_if_missing
    |> cast_assoc(:media)
    |> validate_required(@required)
    |> validate_inclusion(:activity_type, @activity_types)
  end

  defp add_occurred_at_if_missing(%Ecto.Changeset{changes: %{occurred_at: _}} = changeset) do
    changeset
  end

  defp add_occurred_at_if_missing(
         %Ecto.Changeset{data: %GymRats.Model.Workout{occurred_at: nil}} = changeset
       ) do
    changeset |> put_change(:occurred_at, DateTime.utc_now())
  end

  defp add_occurred_at_if_missing(changeset) do
    changeset
  end
end
