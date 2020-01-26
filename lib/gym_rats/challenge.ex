defmodule GymRats.Challenge do
  use Ecto.Schema
  import Ecto.Changeset

  schema "challenges" do
    field :code, :string
    field :end_date, :utc_datetime
    field :name, :string
    field :profile_picture_url, :string
    field :start_date, :utc_datetime
    field :time_zone, :string

    timestamps()
  end

  @doc false
  def changeset(challenge, attrs) do
    challenge
    |> cast(attrs, [:name, :code, :profile_picture_url, :start_date, :end_date, :time_zone])
    |> validate_required([:name, :code, :profile_picture_url, :start_date, :end_date, :time_zone])
  end
end
