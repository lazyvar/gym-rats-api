defmodule GymRats.Model.WorkoutMedium do
  use Ecto.Schema

  alias GymRats.Model.{Workout}

  import Ecto.Changeset

  schema "workout_media" do
    field :url, :string
    field :thumbnail_url, :string
    field :medium_type, :string

    belongs_to :workout, Workout

    timestamps()
  end

  @required ~w(url medium_type)a
  @optional ~w(thumbnail_url)a

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> validate_inclusion(:medium_type, ["image/jpg", "video/mp4"])
  end

  def photo_url(nil) do
    nil
  end

  def photo_url(%{"medium_type" => medium_type} = params) do
    case medium_type do
      "image/jpg" -> params["url"]
      "video/mp4" -> params["thumbnail_url"]
      _ -> nil
    end
  end
end
