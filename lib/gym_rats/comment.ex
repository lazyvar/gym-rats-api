defmodule GymRats.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :content, :string
    field :gym_rats_user_id, :integer
    field :workout_id, :integer

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content, :workout_id, :gym_rats_user_id])
    |> validate_required([:content, :workout_id, :gym_rats_user_id])
  end
end
