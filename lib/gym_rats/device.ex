defmodule GymRats.Device do
  use Ecto.Schema
  import Ecto.Changeset

  schema "devices" do
    field :gym_rats_user_id, :integer
    field :token, :string

    timestamps()
  end

  @doc false
  def changeset(device, attrs) do
    device
    |> cast(attrs, [:gym_rats_user_id, :token])
    |> validate_required([:gym_rats_user_id, :token])
  end
end
