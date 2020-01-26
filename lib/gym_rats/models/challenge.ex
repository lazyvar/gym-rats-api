defmodule GymRats.Model.Challenge do
  use Ecto.Schema

  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:name, :code, :profile_picture_url, :start_date, :end_date]}

  # before_insert :generate_code

  schema "challenges" do
    field :code, :string
    field :end_date, :utc_datetime
    field :name, :string
    field :profile_picture_url, :string
    field :start_date, :utc_datetime
    field :time_zone, :string

    timestamps()
  end

  @required ~w(name code start_date end_date time_zone)a
  @optional ~w(profile_picture_url code)a

  def changeset(challenge, attrs) do
    challenge
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
  end

  # defp generate_code(changeset) do
  #   inspect changeset
  # end
end
