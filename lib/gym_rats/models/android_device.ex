defmodule GymRats.Model.AndroidDevice do
  use Ecto.Schema

  alias GymRats.Model.Account

  import Ecto.Changeset

  schema "android_devices" do
    field :token, :string

    belongs_to :account, Account

    timestamps()
  end

  @required ~w(account_id token)a
  @optional ~w()a

  def changeset(device, attrs) do
    device
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
  end
end
