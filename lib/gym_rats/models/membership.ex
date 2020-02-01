defmodule GymRats.Model.Membership do
  use Ecto.Schema
  
  import Ecto.Changeset

  schema "memberships" do
    field :owner, :boolean, default: false
    
    belongs_to :account, Account, foreign_key: :gym_rats_user_id
    belongs_to :challenge, Challenge

    timestamps()
  end

  @required ~w(gym_rats_user_id challenge_id code owner)a
  @optional ~w()a

  def changeset(membership, attrs) do
    membership
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
  end
end
