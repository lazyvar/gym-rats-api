defmodule GymRats.Membership do
  use Ecto.Schema
  import Ecto.Changeset

  schema "memberships" do
    field :owner, :boolean, default: false
    field :gym_rats_user_id, :integer
    field :challenge_id, :integer
    
    timestamps()
  end

  @doc false
  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:owner])
    |> validate_required([:owner])
  end
end
