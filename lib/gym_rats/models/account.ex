defmodule GymRats.Model.Account do
  use Ecto.Schema

  import Ecto.Changeset

  alias GymRats.Model.Account
  alias GymRats.Model.Challenge
  alias GymRats.Model.Membership
  alias GymRats.Model.Workout
  
  @derive {Jason.Encoder, only: [:id, :email, :full_name, :profile_picture_url]}

  schema "gym_rats_users" do
    field :email, :string
    field :full_name, :string
    field :password_digest, :string
    field :password, :string, virtual: true
    field :profile_picture_url, :string
    field :reset_password_token, :string
    field :reset_password_token_expiration, :utc_datetime

    has_many :workouts, Workout, foreign_key: :gym_rats_user_id
    many_to_many(:challenges, Challenge, join_through: "memberships", join_keys: [gym_rats_user_id: :id, challenge_id: :id])

    timestamps()
  end

  @required ~w(full_name email)a
  @optional ~w(reset_password_token reset_password_token_expiration profile_picture_url)a

  def changeset(account, attrs) do
    account
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> unique_constraint(:email)
  end

  def registration_changeset(attrs) do
    %Account{}
    |> changeset(attrs)
    |> cast(attrs, [:password])
    |> validate_required(:password)
    |> validate_length(:password, min: 6)
    |> put_password_hash()
  end

  def with_token(account) do
    claims = %{"user_id" => account.id}
    jwt = GymRats.Token.generate_and_sign!(claims)
    account |> Map.put(:token, jwt)
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} -> 
        put_change(changeset, :password_digest, Bcrypt.hash_pwd_salt(pass))
      _ -> 
        changeset
    end
  end
end
