defmodule GymRats.Model.Account do
  use Ecto.Schema
  import Ecto.Changeset

  schema "gym_rats_users" do
    field :email, :string
    field :full_name, :string
    field :password_digest, :string
    field :profile_picture_url, :string
    field :reset_password_token, :string
    field :reset_password_token_expiration, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:full_name, :email, :profile_picture_url, :password_digest, :reset_password_token])
    |> validate_required([:full_name, :email, :profile_picture_url, :password_digest, :reset_password_token])
  end
end
