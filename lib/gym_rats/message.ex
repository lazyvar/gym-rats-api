defmodule GymRats.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_messages" do
    field :content, :string
    field :challenge_id, :integer
    field :gym_rats_user_ud, :integer
    
    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end
end