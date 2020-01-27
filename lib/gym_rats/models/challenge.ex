defmodule GymRats.Model.Challenge do
  use Ecto.Schema

  import Ecto.Changeset
  
  alias GymRats.Repo.ChallengeRepo
  alias GymRats.Model.Challenge

  @derive {Jason.Encoder, only: [:id, :name, :code, :profile_picture_url, :start_date, :end_date]}

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

  def new_changeset(params) do
    params = params |> Map.put("code", generate_code)
    changeset(%Challenge{}, params)
  end

  defp generate_code do
    code = ?A..?Z 
      |> Enum.to_list 
      |> Enum.shuffle 
      |> Enum.take(6)
      |> List.to_string
      
    unless ChallengeRepo.exists?(code: code) do
      code
    else
      generate_code
    end
  end
end
