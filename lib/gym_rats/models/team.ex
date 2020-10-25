defmodule GymRats.Model.Team do
  use Ecto.Schema

  alias GymRats.Model.{Challenge, TeamMembership}

  import Ecto.Changeset

  schema "teams" do
    field :name, :string
    field :photo_url, :string

    belongs_to :challenge, Challenge
    has_many :team_memberships, TeamMembership
    has_many :members, through: [:team_memberships, :account]

    timestamps()
  end

  @required ~w(name challenge_id)a
  @optional ~w(photo_url)a

  def changeset(team, attrs) do
    team
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
  end
end
