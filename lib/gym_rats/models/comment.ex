defmodule GymRats.Model.Comment do
  use Ecto.Schema

  alias GymRats.Model.{Account, Workout}
  
  import Ecto.Changeset

  schema "comments" do
    field :content, :string

    belongs_to :account, Account, foreign_key: :gym_rats_user_id
    belongs_to :workout, Workout

    timestamps()
  end

  @required ~w(content)a
  @optional ~w()a

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
  end
end
