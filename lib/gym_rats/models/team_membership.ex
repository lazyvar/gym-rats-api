defmodule GymRats.Model.TeamMembership do
  use Ecto.Schema

  alias GymRats.Model.{Team, Account}

  import Ecto.Changeset

  @primary_key false
  schema "team_memberships" do
    belongs_to :account, Account, primary_key: true
    belongs_to :team, Team, primary_key: true

    timestamps()
  end

  @required ~w(account_id team_id)a
  @optional ~w()a

  def changeset(team_membership, attrs) do
    team_membership
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
  end
end
