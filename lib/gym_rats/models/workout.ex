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

    belongs_to :account, Account, foreign_key: :gym_rats_user_id
    belongs_to :challenge, Challenge

    timestamps()
  end

  @required ~w(gym_rats_user_id challenge_id title)a
  @optional ~w(steps points steps calories description distance duration google_place_id photo_url)a

  def changeset(workout, attrs) do
    workout
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
  end
end
