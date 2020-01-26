defmodule GymRats.Model.Workout do
  use Ecto.Schema
  import Ecto.Changeset

  schema "workouts" do
    field :calories, :integer
    field :challenge_id, :integer
    field :description, :string
    field :distance, :string
    field :duration, :integer
    field :google_place_id, :string
    field :gym_rats_user_id, :integer
    field :photo_url, :string
    field :points, :integer
    field :steps, :integer
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(workout, attrs) do
    workout
    |> cast(attrs, [:gym_rats_user_id, :title, :description, :photo_url, :google_place_id, :challenge_id, :duration, :distance, :steps, :calories, :points])
    |> validate_required([:gym_rats_user_id, :title, :description, :photo_url, :google_place_id, :challenge_id, :duration, :distance, :steps, :calories, :points])
  end
end
