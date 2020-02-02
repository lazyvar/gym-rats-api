defmodule GymRats.Model.Device do
  use Ecto.Schema

  import Ecto.Changeset

  schema "devices" do
    field :token, :string

    belongs_to :account, Account, foreign_key: :gym_rats_user_id

    timestamps()
  end

  @required ~w(gym_rats_user_id token)a
  @optional ~w()a
  
  def changeset(device, attrs) do
    device
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
  end
end
