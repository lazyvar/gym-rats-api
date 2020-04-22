defmodule GymRats.Model.Challenge do
  use Ecto.Schema

  import Ecto.Changeset

  alias GymRats.Repo.ChallengeRepo
  alias GymRats.Model.{Challenge, Membership, Account, Workout}

  schema "challenges" do
    field :code, :string
    field :end_date, :utc_datetime_usec
    field :name, :string
    field :profile_picture_url, :string
    field :start_date, :utc_datetime_usec
    field :time_zone, :string
    field :description, :string
    field :score_by, :string

    has_many :workouts, Workout
    has_many :memberships, Membership

    many_to_many(:accounts, Account,
      join_through: "memberships",
      join_keys: [challenge_id: :id, gym_rats_user_id: :id]
    )

    timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
  end

  @required ~w(name code start_date end_date time_zone)a
  @optional ~w(profile_picture_url code description score_by)a

  def changeset(challenge, attrs) do
    challenge
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> validate_inclusion(:score_by, [
      "workouts",
      "duration",
      "distance",
      "steps",
      "calories",
      "points"
    ])
  end

  def new_changeset(params) do
    params = params |> Map.put("code", generate_code())
    changeset(%Challenge{}, params)
  end

  defp generate_code do
    code =
      ?A..?Z
      |> Enum.to_list()
      |> Enum.shuffle()
      |> Enum.take(6)
      |> List.to_string()

    unless ChallengeRepo.exists?(code: code) do
      code
    else
      generate_code()
    end
  end
end
