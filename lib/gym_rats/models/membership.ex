defmodule GymRats.Model.Membership do
  use Ecto.Schema

  alias GymRats.Model.{Account, Challenge}

  import Ecto.Changeset

  @primary_key false
  schema "memberships" do
    field :owner, :boolean, default: false

    belongs_to :account, Account, foreign_key: :gym_rats_user_id, primary_key: true
    belongs_to :challenge, Challenge, primary_key: true

    timestamps(inserted_at: :created_at)
  end

  @required ~w(gym_rats_user_id challenge_id owner)a
  @optional ~w()a

  def changeset(membership, attrs) do
    membership
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
  end
end
