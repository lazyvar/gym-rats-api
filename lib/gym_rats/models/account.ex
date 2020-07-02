defmodule GymRats.Model.Account do
  use Ecto.Schema

  import Ecto.Changeset

  alias GymRats.Model.{Challenge, Workout, Membership, Comment}

  schema "gym_rats_users" do
    field :email, :string
    field :full_name, :string
    field :password_digest, :string
    field :current_password, :string, virtual: true
    field :password, :string, virtual: true
    field :profile_picture_url, :string
    field :reset_password_token, :string
    field :reset_password_token_expiration, :utc_datetime_usec
    field :workout_notifications_enabled, :boolean
    field :comment_notifications_enabled, :boolean
    field :chat_message_notifications_enabled, :boolean

    has_many :workouts, Workout, foreign_key: :gym_rats_user_id
    has_many :comments, Comment, foreign_key: :gym_rats_user_id
    has_many :memberships, Membership, foreign_key: :gym_rats_user_id

    many_to_many(:challenges, Challenge,
      join_through: "memberships",
      join_keys: [gym_rats_user_id: :id, challenge_id: :id]
    )

    timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
  end

  @required ~w(full_name email)a
  @optional ~w(reset_password_token reset_password_token_expiration profile_picture_url workout_notifications_enabled comment_notifications_enabled chat_message_notifications_enabled)a

  def changeset(account, attrs) do
    account
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> update_change(:full_name, &String.trim/1)
    |> update_change(:email, &String.trim/1)
    |> unique_constraint(:email, name: "index_gym_rats_users_on_email")
  end

  def registration_changeset(account, attrs) do
    account
    |> changeset(attrs)
    |> cast(attrs, [:password])
    |> validate_required(:password)
    |> validate_length(:password, min: 6)
    |> put_password_hash()
  end

  def update_password_changeset(account, attrs) do
    account
    |> changeset(attrs)
    |> cast(attrs, [:password, :current_password])
    |> validate_required([:password, :current_password])
    |> validate_password_update()
    |> validate_length(:password, min: 6)
    |> put_password_hash()
  end

  def put_token(account) do
    claims = %{"user_id" => account.id}
    jwt = GymRats.Token.generate_and_sign!(claims)
    account |> Map.put(:token, jwt)
  end

  defp validate_password_update(changeset) do
    validate_change(changeset, :current_password, fn _field, value ->
      if Bcrypt.verify_pass(value, changeset.data.password_digest) do
        []
      else
        [{:current_password, "is incorrect."}]
      end
    end)
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
